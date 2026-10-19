import jwt from 'jsonwebtoken';

export const signToken = (user) =>
  jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '7d' });

// Middleware: runs before a protected route. Expects header "Authorization: Bearer <token>".
export function requireAuth(req, res, next) {
  const token = (req.headers.authorization || '').replace('Bearer ', '');
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET); // { id, role }
    next();
  } catch {
    res.status(401).json({ error: 'Please log in' });
  }
}
