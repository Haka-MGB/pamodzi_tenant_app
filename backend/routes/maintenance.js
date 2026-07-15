const express = require('express');
const router = express.Router();
const maintenanceController = require('../controllers/maintenanceController');
const { protect } = require('../middleware/auth');
const multer = require('multer');

// Configure multer for image uploads
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB max per file
    files: 5 // Max 5 files
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'), false);
    }
  }
});

// All routes require authentication
router.use(protect);

// Get all maintenance issues for tenant
router.get('/', maintenanceController.getIssues);

// Get single maintenance issue
router.get('/:id', maintenanceController.getIssue);

// Create new maintenance issue with photos
router.post('/', upload.array('photos', 5), maintenanceController.createIssue);

// Update maintenance issue
router.put('/:id', maintenanceController.updateIssue);

// Delete maintenance issue
router.delete('/:id', maintenanceController.deleteIssue);

module.exports = router;
