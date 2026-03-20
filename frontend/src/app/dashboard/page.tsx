"use client"

import { useState, useCallback, useEffect } from "react"
import { useRouter } from "next/navigation"
import { useAuthStore } from "@/store/auth.store"
import { authApi } from "@/lib/api/auth"
import { useTasks } from "@/hooks/useTasks"
import { Task } from "@/types"
import TaskCard from "@/components/TaskCard"
import TaskModal from "@/components/TaskModal"
import { TaskFilters } from "@/lib/api/tasks"
import {
	CheckSquare,
	LogOut,
	Plus,
	Search,
	ChevronLeft,
	ChevronRight,
	SlidersHorizontal,
} from "lucide-react"

export default function DashboardPage() {
	const router = useRouter()
	const { user, refreshToken, accessToken, clear } = useAuthStore()
	useEffect(() => {
		if (!user && !accessToken) {
			window.location.href = "/auth/login"
		}
	}, [user, accessToken])

	const [filters, setFilters] = useState<TaskFilters>({ page: 1, limit: 10 })
	const [searchInput, setSearchInput] = useState("")
	const [showModal, setShowModal] = useState(false)
	const [editingTask, setEditingTask] = useState<Task | null>(null)

	const { data, isLoading, isError } = useTasks(filters)

	const handleSearch = useCallback(
		(e: React.FormEvent) => {
			e.preventDefault()
			setFilters((f) => ({ ...f, search: searchInput || undefined, page: 1 }))
		},
		[searchInput],
	)

	const handleFilter = (key: keyof TaskFilters, value: string) => {
		setFilters((f) => ({ ...f, [key]: value || undefined, page: 1 }))
	}

	const handleLogout = async () => {
		if (refreshToken) await authApi.logout(refreshToken).catch(() => {})
		clear()
		router.push("/auth/login")
	}

	const openEdit = (task: Task) => {
		setEditingTask(task)
		setShowModal(true)
	}
	const closeModal = () => {
		setShowModal(false)
		setEditingTask(null)
	}

	const total = data?.pagination.total || 0
	const tasks = data?.tasks || []

	return (
		<div className="min-h-screen bg-gray-950">
			<header className="border-b border-gray-800 bg-gray-900/50 sticky top-0 z-10 backdrop-blur-sm">
				<div className="max-w-5xl mx-auto px-4 h-14 flex items-center justify-between">
					<div className="flex items-center gap-2">
						<CheckSquare className="w-5 h-5 text-indigo-400" />
						<span className="font-semibold text-white">TaskFlow</span>
					</div>
					<div className="flex items-center gap-3">
						<span className="text-sm text-gray-400 hidden sm:block">
							{user?.name}
						</span>
						<button
							onClick={handleLogout}
							className="flex items-center gap-1.5 text-sm text-gray-400 hover:text-white transition-colors">
							<LogOut className="w-4 h-4" />
							<span className="hidden sm:block">Logout</span>
						</button>
					</div>
				</div>
			</header>

			<main className="max-w-5xl mx-auto px-4 py-6">
				<div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-6">
					{[
						{ label: "Total", value: total, color: "text-white" },
						{
							label: "Pending",
							value: tasks.filter((t) => t.status === "PENDING").length,
							color: "text-gray-400",
						},
						{
							label: "In Progress",
							value: tasks.filter((t) => t.status === "IN_PROGRESS").length,
							color: "text-blue-400",
						},
						{
							label: "Completed",
							value: tasks.filter((t) => t.status === "COMPLETED").length,
							color: "text-green-400",
						},
					].map((s) => (
						<div
							key={s.label}
							className="bg-gray-900 border border-gray-800 rounded-xl p-4">
							<p className="text-xs text-gray-500">{s.label}</p>
							<p className={`text-2xl font-bold mt-1 ${s.color}`}>{s.value}</p>
						</div>
					))}
				</div>

				<div className="flex flex-col sm:flex-row gap-3 mb-4">
					<form onSubmit={handleSearch} className="flex gap-2 flex-1">
						<div className="relative flex-1">
							<Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" />
							<input
								value={searchInput}
								onChange={(e) => setSearchInput(e.target.value)}
								placeholder="Search tasks..."
								className="w-full pl-9 pr-4 py-2 bg-gray-900 border border-gray-800 rounded-lg text-white text-sm focus:outline-none focus:border-indigo-500 placeholder-gray-500"
							/>
						</div>
						<button
							type="submit"
							className="px-4 py-2 bg-gray-800 hover:bg-gray-700 text-white rounded-lg text-sm transition-colors">
							Search
						</button>
					</form>
					<div className="flex gap-2 items-center">
						<SlidersHorizontal className="w-4 h-4 text-gray-500" />
						<select
							onChange={(e) => handleFilter("status", e.target.value)}
							className="px-3 py-2 bg-gray-900 border border-gray-800 rounded-lg text-white text-sm focus:outline-none focus:border-indigo-500">
							<option value="">All Status</option>
							<option value="PENDING">Pending</option>
							<option value="IN_PROGRESS">In Progress</option>
							<option value="COMPLETED">Completed</option>
						</select>
						<select
							onChange={(e) => handleFilter("priority", e.target.value)}
							className="px-3 py-2 bg-gray-900 border border-gray-800 rounded-lg text-white text-sm focus:outline-none focus:border-indigo-500">
							<option value="">All Priority</option>
							<option value="HIGH">High</option>
							<option value="MEDIUM">Medium</option>
							<option value="LOW">Low</option>
						</select>
						<button
							onClick={() => {
								setEditingTask(null)
								setShowModal(true)
							}}
							className="flex items-center gap-1.5 px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white rounded-lg text-sm font-medium transition-colors whitespace-nowrap">
							<Plus className="w-4 h-4" />
							New task
						</button>
					</div>
				</div>

				{isLoading && (
					<div className="space-y-3">
						{[...Array(5)].map((_, i) => (
							<div
								key={i}
								className="bg-gray-900 border border-gray-800 rounded-xl p-4 animate-pulse h-20"
							/>
						))}
					</div>
				)}

				{isError && (
					<div className="text-center py-12 text-red-400 text-sm">
						Failed to load tasks. Please try again.
					</div>
				)}

				{!isLoading && !isError && (
					<>
						{tasks.length === 0 ? (
							<div className="text-center py-16">
								<CheckSquare className="w-12 h-12 text-gray-700 mx-auto mb-3" />
								<p className="text-gray-500 text-sm">No tasks found</p>
								<button
									onClick={() => setShowModal(true)}
									className="mt-4 text-indigo-400 hover:text-indigo-300 text-sm">
									Create your first task
								</button>
							</div>
						) : (
							<div className="space-y-2">
								{tasks.map((task) => (
									<TaskCard key={task.id} task={task} onEdit={openEdit} />
								))}
							</div>
						)}

						{data && data.pagination.totalPages > 1 && (
							<div className="flex items-center justify-between mt-6 pt-4 border-t border-gray-800">
								<p className="text-sm text-gray-500">
									Page {data.pagination.page} of {data.pagination.totalPages} ·{" "}
									{data.pagination.total} tasks
								</p>
								<div className="flex gap-2">
									<button
										onClick={() =>
											setFilters((f) => ({ ...f, page: (f.page || 1) - 1 }))
										}
										disabled={(filters.page || 1) <= 1}
										className="p-2 bg-gray-900 border border-gray-800 rounded-lg text-gray-400 hover:text-white disabled:opacity-40 disabled:cursor-not-allowed transition-colors">
										<ChevronLeft className="w-4 h-4" />
									</button>
									<button
										onClick={() =>
											setFilters((f) => ({ ...f, page: (f.page || 1) + 1 }))
										}
										disabled={(filters.page || 1) >= data.pagination.totalPages}
										className="p-2 bg-gray-900 border border-gray-800 rounded-lg text-gray-400 hover:text-white disabled:opacity-40 disabled:cursor-not-allowed transition-colors">
										<ChevronRight className="w-4 h-4" />
									</button>
								</div>
							</div>
						)}
					</>
				)}
			</main>

			{showModal && <TaskModal task={editingTask} onClose={closeModal} />}
		</div>
	)
}
