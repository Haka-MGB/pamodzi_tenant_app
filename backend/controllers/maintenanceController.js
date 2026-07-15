const MaintenanceIssue = require('../models/MaintenanceIssue');
const Lease = require('../models/Lease');
const Notification = require('../models/Notification');
const cloudinary = require('cloudinary').v2;

// Configure Cloudinary (optional - for image uploads)
if (process.env.CLOUDINARY_CLOUD_NAME) {
  cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
  });
}

// @desc    Get all maintenance issues for tenant
// @route   GET /api/v1/maintenance
// @access  Private
exports.getIssues = async (req, res) => {
  try {
    const { status, priority } = req.query;

    const query = { tenant: req.user.id };
    if (status) query.status = status;
    if (priority) query.priority = priority;

    const issues = await MaintenanceIssue.find(query)
      .populate('property', 'name address')
      .populate('assignedTo', 'firstName lastName phone')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: issues.length,
      issues
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to get maintenance issues',
      error: error.message
    });
  }
};

// @desc    Get single maintenance issue
// @route   GET /api/v1/maintenance/:id
// @access  Private
exports.getIssue = async (req, res) => {
  try {
    const issue = await MaintenanceIssue.findById(req.params.id)
      .populate('property', 'name address')
      .populate('assignedTo', 'firstName lastName phone email')
      .populate('timeline.performedBy', 'firstName lastName');

    if (!issue) {
      return res.status(404).json({
        success: false,
        message: 'Maintenance issue not found'
      });
    }

    // Check authorization
    if (issue.tenant.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this issue'
      });
    }

    res.json({
      success: true,
      issue
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to get maintenance issue',
      error: error.message
    });
  }
};

// @desc    Create new maintenance issue
// @route   POST /api/v1/maintenance
// @access  Private
exports.createIssue = async (req, res) => {
  try {
    const { category, title, description, priority } = req.body;

    // Get tenant's active lease
    const lease = await Lease.findOne({
      tenant: req.user.id,
      status: 'active'
    });

    if (!lease) {
      return res.status(404).json({
        success: false,
        message: 'No active lease found'
      });
    }

    // Handle photo uploads
    const photos = [];
    if (req.files && req.files.length > 0) {
      // If Cloudinary is configured, upload there
      if (process.env.CLOUDINARY_CLOUD_NAME) {
        for (const file of req.files) {
          try {
            const result = await new Promise((resolve, reject) => {
              const uploadStream = cloudinary.uploader.upload_stream(
                {
                  folder: 'maintenance_issues',
                  resource_type: 'image'
                },
                (error, result) => {
                  if (error) reject(error);
                  else resolve(result);
                }
              );
              uploadStream.end(file.buffer);
            });

            photos.push({
              url: result.secure_url,
              publicId: result.public_id
            });
          } catch (uploadError) {
            console.error('Image upload error:', uploadError);
          }
        }
      } else {
        // If no Cloudinary, store base64 (not recommended for production)
        for (const file of req.files) {
          const base64 = file.buffer.toString('base64');
          photos.push({
            url: `data:${file.mimetype};base64,${base64}`
          });
        }
      }
    }

    // Create maintenance issue
    const issue = await MaintenanceIssue.create({
      tenant: req.user.id,
      property: lease.property,
      category,
      title,
      description,
      priority: priority || 'Medium',
      photos
    });

    // Notify landlord
    await Notification.create({
      recipient: lease.landlord,
      type: 'maintenance',
      title: 'New Maintenance Request',
      message: `${req.user.firstName} ${req.user.lastName} reported: ${title}`,
      relatedEntity: {
        entityType: 'MaintenanceIssue',
        entityId: issue._id
      },
      priority: priority === 'Urgent' ? 'high' : 'normal'
    });

    // Notify tenant
    await Notification.create({
      recipient: req.user.id,
      type: 'maintenance',
      title: 'Maintenance Request Submitted',
      message: `Your request "${title}" has been submitted successfully.`,
      relatedEntity: {
        entityType: 'MaintenanceIssue',
        entityId: issue._id
      }
    });

    res.status(201).json({
      success: true,
      message: 'Maintenance issue created successfully',
      issue
    });
  } catch (error) {
    console.error('Create maintenance issue error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create maintenance issue',
      error: error.message
    });
  }
};

// @desc    Update maintenance issue
// @route   PUT /api/v1/maintenance/:id
// @access  Private
exports.updateIssue = async (req, res) => {
  try {
    let issue = await MaintenanceIssue.findById(req.params.id);

    if (!issue) {
      return res.status(404).json({
        success: false,
        message: 'Maintenance issue not found'
      });
    }

    // Check authorization
    if (issue.tenant.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this issue'
      });
    }

    // Only allow certain fields to be updated by tenant
    const { description, priority } = req.body;
    
    if (description) issue.description = description;
    if (priority) issue.priority = priority;

    await issue.save();

    res.json({
      success: true,
      message: 'Maintenance issue updated successfully',
      issue
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to update maintenance issue',
      error: error.message
    });
  }
};

// @desc    Delete maintenance issue
// @route   DELETE /api/v1/maintenance/:id
// @access  Private
exports.deleteIssue = async (req, res) => {
  try {
    const issue = await MaintenanceIssue.findById(req.params.id);

    if (!issue) {
      return res.status(404).json({
        success: false,
        message: 'Maintenance issue not found'
      });
    }

    // Check authorization
    if (issue.tenant.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this issue'
      });
    }

    // Only allow deletion if status is 'Open'
    if (issue.status !== 'Open') {
      return res.status(400).json({
        success: false,
        message: 'Can only delete issues with Open status'
      });
    }

    // Delete photos from Cloudinary if configured
    if (process.env.CLOUDINARY_CLOUD_NAME && issue.photos) {
      for (const photo of issue.photos) {
        if (photo.publicId) {
          try {
            await cloudinary.uploader.destroy(photo.publicId);
          } catch (err) {
            console.error('Failed to delete image from Cloudinary:', err);
          }
        }
      }
    }

    await issue.deleteOne();

    res.json({
      success: true,
      message: 'Maintenance issue deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to delete maintenance issue',
      error: error.message
    });
  }
};
