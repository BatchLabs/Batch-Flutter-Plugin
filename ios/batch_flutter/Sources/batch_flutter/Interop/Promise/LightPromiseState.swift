
import Foundation

/// State container for promise data
final class LightPromiseState: @unchecked Sendable {
	var status: LightPromise.Status = .pending
	var executor: LightPromiseExecutor = .synchronous
	var thenBlocks: [LightPromise.ThenBlock] = []
	var catchBlocks: [LightPromise.CatchBlock] = []

	func setExecutor(_ newExecutor: LightPromiseExecutor) {
		executor = newExecutor
	}

	func addThenBlock(_ block: @escaping LightPromise.ThenBlock) {
		switch status {
		case .pending:
			thenBlocks.append(block)
		case .resolved(let value):
			executor.execute { block(value) }
		case .rejected:
			break
		}
	}

	func addCatchBlock(_ block: @escaping LightPromise.CatchBlock) {
		switch status {
		case .pending:
			catchBlocks.append(block)
		case .resolved:
			break
		case .rejected(let error):
			executor.execute { block(error) }
		}
	}

	func resolve(with value: LightPromiseObject) {
		guard case .pending = status else { return }

		status = .resolved(value: value)
		let blocks = thenBlocks
		thenBlocks.removeAll()

		for block in blocks {
			executor.execute { block(value) }
		}
	}

	func reject(with error: Error) {
		guard case .pending = status else { return }

		status = .rejected(error: error)
		let blocks = catchBlocks
		catchBlocks.removeAll()

		for block in blocks {
			executor.execute { block(error) }
		}
	}
}
