public class SQL {

	public var table: String
	public var operation: Operation

	public var filters: [Filter]?
	public var limit: Int?
	public var data: [String: String]?

	public enum Operation {
		case SELECT, DELETE, INSERT, UPDATE
	}

	public init(operation: Operation, table: String) {
		self.operation = operation
		self.table = table
	}

	public var query: String {
		var query: [String] = []

		switch self.operation {
		case .SELECT:
			query.append("SELECT * FROM")
		case .DELETE:
			query.append("DELETE FROM")
		case .INSERT:
			query.append("INSERT INTO")
		case .UPDATE:
			query.append("UPDATE")
		}
		// UPDATE table_name
		// SET column1 = value1, column2 = value2...., columnN = valueN
		// WHERE [condition];

		query.append("`\(self.table)`")

		if let data = self.data {

			if self.operation == .INSERT {

				var columns: [String] = []
				var values: [String] = []

				for (key, val) in data {
					columns.append("`\(key)`")

					if val == "NULL" {
						values.append("\(val)")
					} else {
						values.append("'\(val)'")
					}
				}

				let columnsString = columns.joinWithSeparator(", ")
				let valuesString = values.joinWithSeparator(", ")
				query.append("(\(columnsString)) VALUES (\(valuesString))")

			} else if self.operation == .UPDATE {

				var updates: [String] = []

				for (key, val) in data {

					let value: String

					if val == "NULL" {
						value = "\(val)"
					} else {
						value = "'\(val)'"
					}

					updates.append("`\(key)` = \(value)")

				}

				let updatesString = updates.joinWithSeparator(", ")
				query.append("SET \(updatesString)")

			}

		}

		if let filters = self.filters where filters.count > 0 {
			var filterStrings = [String]()

			for filter in filters {
				let op: String

				switch filter.comparison {
					case Filter.Equality.Equals:
						op = "="
					case Filter.Equality.NotEquals:
						op = "!="
				 	case Filter.Equality.GreaterThan:
						op = ">"
				 	case Filter.Equality.LessThan:
						op = "<"
				 	case Filter.Equality.GreaterThanOrEquals:
						op = ">="
				 	case Filter.Equality.LessThanOrEquals:
						op = "<="
					case Filter.Subset.In:
						op = "IN"
					case Filter.Subset.NotIn:
						op = "NOT IN"
					default:
						op = ""
				}

				var value: String = ""

				if let _ = filter.comparison as? Filter.Equality {
					value = filter.operand.value
				} else if let _ = filter.comparison as? Filter.Subset {
					value = "\(filter.operand.valueSet)"
				}

				filterStrings.append("`\(filter.key)` \(op) ''\(value)'")
			}

			query.append("WHERE \(filterStrings.joinWithSeparator(" AND "))")
		}

		if let limit = self.limit {
			query.append("LIMIT \(limit)")
		}

		let queryString = query.joinWithSeparator(" ")

		self.log(queryString)

		return queryString + ";"
	}

	func log(message: Any) {
		print("[SQL] \(message)")
	}
}
