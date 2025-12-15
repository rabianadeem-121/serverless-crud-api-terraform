const { getClient } = require("./db");

exports.handler = async (event) => {
  const client = getClient();
  await client.connect();

  try {
    const method = event.httpMethod;
    const id = event.pathParameters?.id;

    if (method === "POST") {
      const body = JSON.parse(event.body);
      const res = await client.query(
        "INSERT INTO users(name,email) VALUES($1,$2) RETURNING *",
        [body.name, body.email]
      );
      return response(201, res.rows[0]);
    }

    if (method === "GET" && id) {
      const res = await client.query(
        "SELECT * FROM users WHERE id=$1",
        [id]
      );
      return response(200, res.rows[0]);
    }

    if (method === "GET") {
      const res = await client.query("SELECT * FROM users");
      return response(200, res.rows);
    }

    if (method === "PUT") {
      const body = JSON.parse(event.body);
      const res = await client.query(
        "UPDATE users SET name=$1,email=$2 WHERE id=$3 RETURNING *",
        [body.name, body.email, id]
      );
      return response(200, res.rows[0]);
    }

    if (method === "DELETE") {
      await client.query("DELETE FROM users WHERE id=$1", [id]);
      return response(204, null);
    }

    return response(400, "Invalid request");
  } catch (err) {
    console.error(err);
    return response(500, "Internal Server Error");
  } finally {
    await client.end();
  }
};

const response = (statusCode, body) => ({
  statusCode,
  body: JSON.stringify(body),
});
