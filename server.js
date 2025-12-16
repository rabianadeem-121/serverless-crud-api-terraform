require('dotenv').config();
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

const userRoutes = require('./routes/users');
app.use('/users', userRoutes);

app.listen(port, '0.0.0.0', () => console.log(`Server running on port ${port}`));
