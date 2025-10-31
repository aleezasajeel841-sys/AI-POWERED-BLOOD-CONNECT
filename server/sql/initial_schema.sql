-- Initial schema for AI Powered Blood Connect
CREATE DATABASE IF NOT EXISTS blood_connect;
USE blood_connect;

-- roles
CREATE TABLE IF NOT EXISTS roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE
);

-- users (shared for donors/receivers/hospitals/admin)
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  role_id INT NOT NULL,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  phone VARCHAR(30),
  city VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE RESTRICT
);

-- donors table
CREATE TABLE IF NOT EXISTS donors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  blood_group VARCHAR(5) NOT NULL,
  last_donated DATE,
  eligible BOOLEAN DEFAULT TRUE,
  points INT DEFAULT 0,
  badges JSON,
  availability_status BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- hospitals
CREATE TABLE IF NOT EXISTS hospitals (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  name VARCHAR(200) NOT NULL,
  address TEXT,
  city VARCHAR(100),
  phone VARCHAR(50),
  verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- blood_stock
CREATE TABLE IF NOT EXISTS blood_stock (
  id INT AUTO_INCREMENT PRIMARY KEY,
  hospital_id INT NOT NULL,
  blood_group VARCHAR(5) NOT NULL,
  units INT DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE
);

-- requests
CREATE TABLE IF NOT EXISTS requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  receiver_id INT NOT NULL,
  hospital_id INT,
  blood_group VARCHAR(5) NOT NULL,
  units_needed INT NOT NULL,
  urgency ENUM('normal','urgent') DEFAULT 'normal',
  status ENUM('open','notified','accepted','fulfilled','declined') DEFAULT 'open',
  location VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE SET NULL
);

-- donations
CREATE TABLE IF NOT EXISTS donations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  donor_id INT NOT NULL,
  request_id INT,
  hospital_id INT,
  donated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  units INT DEFAULT 1,
  notes TEXT,
  FOREIGN KEY (donor_id) REFERENCES donors(id) ON DELETE CASCADE,
  FOREIGN KEY (request_id) REFERENCES requests(id) ON DELETE SET NULL,
  FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE SET NULL
);

-- notifications
CREATE TABLE IF NOT EXISTS notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  type VARCHAR(100),
  payload JSON,
  read_flag BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- payments (for events/campaigns)
CREATE TABLE IF NOT EXISTS payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  gateway VARCHAR(100),
  transaction_id VARCHAR(200),
  status VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- events
CREATE TABLE IF NOT EXISTS events (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(250) NOT NULL,
  description TEXT,
  organizer_id INT,
  start_date DATETIME,
  end_date DATETIME,
  location VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- backups
CREATE TABLE IF NOT EXISTS backups (
  id INT AUTO_INCREMENT PRIMARY KEY,
  file_path VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- seed roles
INSERT IGNORE INTO roles (id, name) VALUES (1,'admin'),(2,'hospital'),(3,'donor'),(4,'receiver');