<div align="center">
  <img src="assets/U-NOTES%20LOGO%20Orange.svg" alt="U-Notes Logo" width="200" style="margin-bottom: 20px;" />

  # U-Notes // Backend API

  ![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
  ![Express](https://img.shields.io/badge/Express.js-000000?style=for-the-badge&logo=express&logoColor=white)
  ![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white)
  ![JWT](https://img.shields.io/badge/JSON_Web_Tokens-000000?style=for-the-badge&logo=json-web-tokens&logoColor=white)
</div>

Welcome to the backend repository for **U-Notes**. This Node.js/Express server acts as the secure backbone for the U-Notes platform, handling user authentication, database connections, and (in upcoming modules) strict local file processing.

## Architecture & Security
To ensure maximum security against SQL Injections and data breaches, this backend **does not execute raw SQL queries**. 
Instead, it exclusively maps to **MySQL Stored Procedures**. The Node server acts only as a secure middleware layer to validate requests, issue JWTs, and call the pre-compiled database procedures.

## Key Features
- **Robust Authentication:** Secure user registration and login using `bcrypt` for password hashing and `jsonwebtoken` for stateless session management.
- **Stored Procedure Driven:** 100% of database interactions run through isolated Stored Procedures.
- **Local File Management (Design):** Designed to handle PDF file uploads strictly on the local filesystem (`/uploads`), keeping heavy binaries decoupled from the SQL database.

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
   - Run the provided initialization script to create the DB, tables, and Stored Procedures automatically:
     ```bash
     node setup-db.js
     ```

4. **Environment Variables:**
   Create a `.env` file in the root directory (never commit this file) with the following structure:
   ```env
   DB_HOST=localhost
   DB_USER=root
   DB_PASS=
   DB_NAME=UNotes
   JWT_SECRET=your_super_secret_key
   PORT=5000
   ```

5. **Start the server:**
   ```bash
   node server.js
   ```
   The API will be available at `http://localhost:5000`.

## Project Structure
- `/config`: Database connection instances.
- `/db`: Raw `.sql` initialization files containing schemas and Stored Procedures.
- `/routes`: Express route handlers (e.g., `/api/auth/register`).
- `/uploads`: Ignored directory intended for PDF binary storage.

---
*Built by Ixion Systems.*
