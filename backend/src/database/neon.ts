import * as neon from '@neondatabase/serverless'
import type { Database, Result } from 'wildebeest/backend/src/database'
import type { Env } from 'wildebeest/backend/src/types/env'

export default function make(env: Env): Database {
	return {
		prepare(query: string) {
			return new PreparedStatement(env, query, [])
		},

		dump() {
			throw new Error('not implemented')
		},

		async batch<T = unknown>(statements: PreparedStatement[]): Promise<Result<T>[]> {
			console.log(statements)
			throw new Error('not implemented')
		},

		async exec<T = unknown>(query: string): Promise<Result<T>> {
			console.log(query)
			throw new Error('not implemented')
		},
	}
}

export class PreparedStatement {
	private env: Env
	private query: string
	private values: any[]

	constructor(env: Env, query: string, values: any[]) {
		this.env = env
		this.query = query
		this.values = values
	}

	bind(...values: any[]): PreparedStatement {
		return new PreparedStatement(this.env, this.query, [...this.values, ...values])
	}

	private async connect() {
		const client = new neon.Client(this.env.NEON_DATABASE_URL!)
		console.log(this.env.NEON_DATABASE_URL!)
		await client.connect()

		return client
	}

	async first<T = unknown>(colName?: string): Promise<T> {
		if (colName) {
			throw new Error('not implemented')
		}
		const conn = await this.connect()

        console.log(this.query, this.values);
		const results = await conn.query(this.query, this.values)
		console.log({ results })
		if (results.rows.length !== 1) {
			throw new Error(`expected a single row, returned ${results.rows.length} row(s)`)
		}

		// await conn.end()

		return results.rows[0] as T
	}

	async run<T = unknown>(): Promise<Result<T>> {
		return this.all()
	}

	async all<T = unknown>(): Promise<Result<T>> {
		const conn = await this.connect()
        console.log(this.query, this.values);
		const results = await conn.query(this.query, this.values)
		console.log({ results })

		return {
			results: results.rows as T[],
			success: true,
			meta: {},
		}
	}

	async raw<T = unknown>(): Promise<T[]> {
		throw new Error('not implemented')
	}
}
