import pool from "./db/pool.js";

const testDB = async () => {
  try {
    const res = await pool.query("SELECT NOW()");
    console.log("Database Connected");
    console.log(res.rows);
  } catch (error) {
    console.error(error);
  }
};

testDB();