# U-Notes // Backend API

![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![Express](https://img.shields.io/badge/Express.js-000000?style=for-the-badge&logo=express&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white)
![JWT](https://img.shields.io/badge/JSON_Web_Tokens-000000?style=for-the-badge&logo=json-web-tokens&logoColor=white)
![Multer](https://img.shields.io/badge/Multer-F24E1E?style=for-the-badge&logo=npm&logoColor=white)

Technical documentation for the **U-Notes Backend Repository**. This Node.js/Express server is the secure REST API for the U-Notes platform, managing user authentication, database connections, and file processing.

## Tech Stack & Dependencies
- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** MySQL 8.0+
- **Authentication:** jsonwebtoken (JWT), bcrypt (Password Hashing)
- **File Handling:** Multer (Multipart form data processing)
- **Database Driver:** mysql2/promise

## System Functionalities
- **Stateless Authentication:** User registration and login utilizing JWT for session authorization via HTTP Bearer Headers. Password hashing via `bcrypt`.
- **Stored Procedure Driven Security:** The backend architecture strictly prohibits raw SQL queries. 100% of data querying and mutation operations (Users, Searches, Filters, Uploads) are handled through pre-compiled MySQL Stored Procedures to prevent SQL injection.
- **Local File Management:** Binary files (PDFs) are decoupled from the SQL database. `multer` processes incoming `multipart/form-data`, validates MIME types (`application/pdf`) and size limits (max 30MB), renames them securely, and stores them in the local `/uploads` directory.
- **Data Pagination Algorithms:** Provides a search and filtering endpoint (`/api/notes/search`) that calculates dynamic pagination metadata (21 records per page) optimized for the frontend grid consumption.

## Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Ixion-Systems/U-Note-BackEnd.git
   cd U-Note-BackEnd
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Database Initialization:**
   Ensure you have a local MySQL instance running on port `3306`.
   - Execute the SQL script located at `db/init.sql` directly into your MySQL server. This will create the `UNotes` database, its table schema (users, careers, subjects, notes), and the required Stored Procedures.

4. **Environment Variables:**
   Create a `.env` file in the root directory with the following configuration:
   ```env
   DB_HOST=localhost
   DB_USER=root
   DB_PASS=
   DB_NAME=UNotes
   JWT_SECRET=your_super_secret_key_here
   PORT=5000
   ```

5. **Start the server:**
   ```bash
   # Development mode (nodemon)
   npm run dev
   
   # Production mode
   node server.js
   ```
   The REST API will be available at `http://localhost:5000`.

## Directory Structure
- `/config`: Database connection pool instances.
- `/db`: SQL source files containing schema definitions and Stored Procedures.
- `/routes`: Express route handlers and controller logic (`/api/auth`, `/api/notes`).
- `/uploads`: File system storage path for PDF blobs (ignored by git, maintained via `.gitkeep`).
