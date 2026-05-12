require("dotenv").config();
const express = require("express");
const cors = require("cors");
const { Pool } = require("pg");

const app = express();

// Middleware
app.use(
  cors({
    origin: process.env.ALLOWED_ORIGINS?.split(",") || "*",
    credentials: true,
  })
);
app.use(express.json());

// Database Connection
const pool = new Pool({
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
});

pool.on("error", (err) => {
  console.error("Unexpected error on idle client", err);
});

// Health Check
app.get("/health", (req, res) => {
  res.json({
    status: "Server is running",
    timestamp: new Date(),
    environment: process.env.NODE_ENV,
  });
});

// GET all items
app.get("/api/items", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM items ORDER BY created_at DESC"
    );
    res.json({
      success: true,
      data: result.rows,
      count: result.rowCount,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// GET single item by ID
app.get("/api/items/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query("SELECT * FROM items WHERE id = $1", [id]);

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        error: "Item not found",
      });
    }

    res.json({
      success: true,
      data: result.rows[0],
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// POST create new item
app.post("/api/items", async (req, res) => {
  try {
    const {
      title,
      description,
      price,
      image_url,
      category,
      stock_quantity,
      user_id,
    } = req.body;

    if (!title || price === undefined) {
      return res.status(400).json({
        success: false,
        error: "Title and price are required",
      });
    }

    const result = await pool.query(
      "INSERT INTO items (title, description, price, image_url, category, stock_quantity, user_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW()) RETURNING *",
      [
        title,
        description,
        price,
        image_url,
        category,
        stock_quantity || 0,
        user_id,
      ]
    );

    res.status(201).json({
      success: true,
      data: result.rows[0],
      message: "Item created successfully",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// PUT update item
app.put("/api/items/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, price, image_url, category, stock_quantity } =
      req.body;

    const result = await pool.query(
      "UPDATE items SET title = $1, description = $2, price = $3, image_url = $4, category = $5, stock_quantity = $6, updated_at = NOW() WHERE id = $7 RETURNING *",
      [title, description, price, image_url, category, stock_quantity, id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        error: "Item not found",
      });
    }

    res.json({
      success: true,
      data: result.rows[0],
      message: "Item updated successfully",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// DELETE item
app.delete("/api/items/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      "DELETE FROM items WHERE id = $1 RETURNING id",
      [id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        error: "Item not found",
      });
    }

    res.json({
      success: true,
      message: "Item deleted successfully",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// Search items
app.get("/api/items/search", async (req, res) => {
  try {
    const { q } = req.query;

    if (!q) {
      return res.json({
        success: true,
        data: [],
        message: "Search query is empty",
      });
    }

    const result = await pool.query(
      "SELECT * FROM items WHERE title ILIKE $1 OR description ILIKE $1 OR category ILIKE $1 ORDER BY created_at DESC",
      [`%${q}%`]
    );

    res.json({
      success: true,
      data: result.rows,
      count: result.rowCount,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// ==================== AUTH ENDPOINTS ====================

// POST login
app.post("/api/auth/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    console.log("🔐 Login Request - Email:", email, "Password:", password);

    // Önce tüm kullanıcıları listele
    const allUsers = await pool.query(
      "SELECT id, email, password_hash FROM users"
    );
    console.log("📋 All users in DB:", allUsers.rows);

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: "Email and password are required",
      });
    }

    const result = await pool.query(
      "SELECT id, email FROM users WHERE email = $1 AND password_hash = $2",
      [email, password]
    );

    console.log("✅ Login query result:", result.rows);

    if (result.rowCount === 0) {
      console.log("❌ User not found or password mismatch");
      return res.status(401).json({
        success: false,
        error: "Invalid email or password",
      });
    }

    console.log("✅ Login success!");
    res.json({
      success: true,
      data: result.rows[0],
      message: "Login successful",
    });
  } catch (err) {
    console.error("🚨 Error:", err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// POST signup
app.post("/api/auth/signup", async (req, res) => {
  try {
    const { email, password, full_name } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: "Email and password are required",
      });
    }

    const result = await pool.query(
      "INSERT INTO users (email, password_hash, created_at, updated_at) VALUES ($1, $2, NOW(), NOW()) RETURNING id, email",
      [email, password]
    );

    res.status(201).json({
      success: true,
      data: result.rows[0],
      message: "User created successfully",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// GET user profile
app.get("/api/auth/profile/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      "SELECT id, email, created_at FROM users WHERE id = $1",
      [id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        error: "User not found",
      });
    }

    res.json({
      success: true,
      data: result.rows[0],
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// ==================== GYM LOCATION ENDPOINTS ====================

// GET all gyms
app.get("/api/gyms", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM gyms ORDER BY rating DESC, review_count DESC"
    );
    res.json({
      success: true,
      data: result.rows,
      count: result.rowCount,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// GET gyms near user location
app.get("/api/gyms/nearby", async (req, res) => {
  try {
    const { lat, lng, radius = 10 } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({
        success: false,
        error: "Latitude and longitude are required",
      });
    }

    const result = await pool.query(
      `
      SELECT *,
        (6371 * acos(cos(radians($1)) * cos(radians(latitude)) * cos(radians(longitude) - radians($2)) + sin(radians($1)) * sin(radians(latitude)))) AS distance
      FROM gyms
      HAVING (6371 * acos(cos(radians($1)) * cos(radians(latitude)) * cos(radians(longitude) - radians($2)) + sin(radians($1)) * sin(radians(latitude)))) < $3
      ORDER BY distance ASC
    `,
      [lat, lng, radius]
    );

    res.json({
      success: true,
      data: result.rows,
      count: result.rowCount,
      radius: radius,
      userLocation: { latitude: lat, longitude: lng },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// GET single gym by ID
app.get("/api/gyms/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      `SELECT g.*, 
        COALESCE(json_agg(json_build_object(
          'id', gr.id, 
          'rating', gr.rating, 
          'review_text', gr.review_text,
          'created_at', gr.created_at
        )) FILTER (WHERE gr.id IS NOT NULL), '[]') as reviews
       FROM gyms g
       LEFT JOIN gym_reviews gr ON g.id = gr.gym_id
       WHERE g.id = $1
       GROUP BY g.id`,
      [id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        error: "Gym not found",
      });
    }

    res.json({
      success: true,
      data: result.rows[0],
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// POST add gym
app.post("/api/gyms", async (req, res) => {
  try {
    const {
      name,
      description,
      latitude,
      longitude,
      address,
      phone,
      website,
      opening_hours,
      amenities,
      image_url,
    } = req.body;

    if (!name || latitude === undefined || longitude === undefined) {
      return res.status(400).json({
        success: false,
        error: "Name, latitude, and longitude are required",
      });
    }

    const result = await pool.query(
      `INSERT INTO gyms (name, description, latitude, longitude, address, phone, website, opening_hours, amenities, image_url, created_at, updated_at) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW()) 
       RETURNING *`,
      [
        name,
        description,
        latitude,
        longitude,
        address,
        phone,
        website,
        opening_hours,
        amenities,
        image_url,
      ]
    );

    res.status(201).json({
      success: true,
      data: result.rows[0],
      message: "Gym added successfully",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// PUT update gym
app.put("/api/gyms/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name,
      description,
      latitude,
      longitude,
      address,
      phone,
      website,
      opening_hours,
      amenities,
      image_url,
    } = req.body;

    const result = await pool.query(
      `UPDATE gyms 
       SET name = $1, description = $2, latitude = $3, longitude = $4, address = $5, phone = $6, website = $7, opening_hours = $8, amenities = $9, image_url = $10, updated_at = NOW() 
       WHERE id = $11 
       RETURNING *`,
      [
        name,
        description,
        latitude,
        longitude,
        address,
        phone,
        website,
        opening_hours,
        amenities,
        image_url,
        id,
      ]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        error: "Gym not found",
      });
    }

    res.json({
      success: true,
      data: result.rows[0],
      message: "Gym updated successfully",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// DELETE gym
app.delete("/api/gyms/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      "DELETE FROM gyms WHERE id = $1 RETURNING id",
      [id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        error: "Gym not found",
      });
    }

    res.json({
      success: true,
      message: "Gym deleted successfully",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// ==================== GYM REVIEWS ====================

// POST add gym review
app.post("/api/gyms/:gymId/reviews", async (req, res) => {
  try {
    const { gymId } = req.params;
    const { user_id, rating, review_text } = req.body;

    if (!user_id || !rating || rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        error: "User ID and rating (1-5) are required",
      });
    }

    const reviewResult = await pool.query(
      `INSERT INTO gym_reviews (gym_id, user_id, rating, review_text, created_at) 
       VALUES ($1, $2, $3, $4, NOW()) 
       RETURNING *`,
      [gymId, user_id, rating, review_text]
    );

    const ratingResult = await pool.query(
      `SELECT AVG(rating)::DECIMAL(3,2) as avg_rating, COUNT(*) as count 
       FROM gym_reviews WHERE gym_id = $1`,
      [gymId]
    );

    await pool.query(
      `UPDATE gyms SET rating = $1, review_count = $2, updated_at = NOW() WHERE id = $3`,
      [ratingResult.rows[0].avg_rating, ratingResult.rows[0].count, gymId]
    );

    res.status(201).json({
      success: true,
      data: reviewResult.rows[0],
      message: "Review added successfully",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// ==================== FAVORITE GYMS ====================

// GET user's favorite gyms
app.get("/api/users/:userId/favorites", async (req, res) => {
  try {
    const { userId } = req.params;
    const result = await pool.query(
      `SELECT g.* FROM gyms g
       INNER JOIN favorite_gyms fg ON g.id = fg.gym_id
       WHERE fg.user_id = $1
       ORDER BY fg.added_at DESC`,
      [userId]
    );

    res.json({
      success: true,
      data: result.rows,
      count: result.rowCount,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// POST add gym to favorites
app.post("/api/users/:userId/favorites/:gymId", async (req, res) => {
  try {
    const { userId, gymId } = req.params;

    const result = await pool.query(
      `INSERT INTO favorite_gyms (user_id, gym_id, added_at) 
       VALUES ($1, $2, NOW()) 
       ON CONFLICT (user_id, gym_id) DO UPDATE SET added_at = NOW()
       RETURNING *`,
      [userId, gymId]
    );

    res.status(201).json({
      success: true,
      data: result.rows[0],
      message: "Gym added to favorites",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════╗
║     ✅ SERVER RUNNING SUCCESSFULLY!        ║
╠════════════════════════════════════════════╣
║  🌐 URL: http://localhost:${PORT}          ║
║  📊 Database: ${process.env.DB_NAME}       ║
║  🔐 Environment: ${process.env.NODE_ENV}   ║
╚════════════════════════════════════════════╝
  `);
});

process.on("SIGTERM", () => {
  console.log("SIGTERM received. Shutting down gracefully");
  server.close(() => {
    console.log("Server closed");
    process.exit(0);
  });
});

// DELETE gym from favorites
app.delete("/api/users/:userId/favorites/:gymId", async (req, res) => {
  try {
    const { userId, gymId } = req.params;

    const result = await pool.query(
      "DELETE FROM favorite_gyms WHERE user_id = $1 AND gym_id = $2 RETURNING id",
      [userId, gymId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        error: "Favorite not found",
      });
    }

    res.json({
      success: true,
      message: "Gym removed from favorites",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});
