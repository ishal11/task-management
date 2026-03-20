import "dotenv/config"
import express from "express"
import cors from "cors"
import helmet from "helmet"
import morgan from "morgan"
import cookieParser from "cookie-parser"
import rateLimit from "express-rate-limit"

import authRoutes from "./routes/auth.routes"
import taskRoutes from "./routes/task.routes"

const app = express()
const PORT = process.env.PORT || 5000

app.use(helmet())
// app.use(
// 	cors({
// 		origin: ["http://localhost:3000", "http://10.5.76.8:3000"],
// 		credentials: true,
// 	}),
// )
app.use(cors({ origin: true, credentials: true }))
app.use(morgan("dev"))
app.use(express.json())
app.use(cookieParser())

const limiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 100 })
app.use(limiter)

app.use("/auth", authRoutes)
app.use("/tasks", taskRoutes)

app.get("/health", (_, res) => res.json({ status: "ok" }))

app.use((_, res) => res.status(404).json({ message: "Route not found" }))

app.listen(PORT, () => console.log(`Server running on port ${PORT}`))

export default app
