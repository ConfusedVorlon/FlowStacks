import Foundation

/// A thin wrapper around an array. Stack provides some convenience methods for pushing
/// and popping, and makes it harder to perform navigation operations that SwiftUI does
/// not support.
public struct Stack<E> {
    
    /// The underlying array of screens.
    public internal(set) var array: [E]
    
    /// Initializes the stack with an empty array of screens.
    public init() {
        self.array = []
    }
    
    /// Initializes the stack with a single root screen.
    /// - Parameter root: The root screen.
    public init(root: E) {
        self.array = [root]
    }
    
    /// Pushes a new screen onto the stack.
    /// - Parameter screen: The screen to push.
    public mutating func push(_ screen: E) {
        array.append(screen)
    }
    
    /// Pops a given number of screens off the stack
    /// - Parameter count: The number of screens to pop. Defaults to 1.
    public mutating func pop(count: Int = 1) {
        array = array.dropLast(count)
    }
    
    /// Pops to a given index in the array of screens. The resulting screen count
    /// will be index + 1.
    /// - Parameter index: <#index description#>
    public mutating func popTo(index: Int) {
        array = Array(array.prefix(index + 1))
    }
    
    /// Pops to the root screen (index 0). The resulting screen count
    /// will be 1.
    public mutating func popToRoot() {
        popTo(index: 0)
    }
    
    /// Pops to the topmost (most recently pushed) screen in the stack
    /// that satisfies the given condition. If no screens satisfy the condition,
    /// the screens array will be unchanged.
    /// - Parameter condition: The predicate indicating which screen to pop to.
    /// - Returns: A `Bool` indicating whether a screen was found.
    @discardableResult
    public mutating func popTo(where condition: (E) -> Bool) -> Bool {
        guard let index = array.lastIndex(where: condition) else {
            return false
        }
        popTo(index: index)
        return true
    }
    
    /// Replaces the current screen array with a new array. The count of the new
    /// array should be no more than the previous stack's count plus one.
    /// - Parameter newArray: The new screens array.
    public mutating func replaceStack(with newArray: [E]) {
        assert(
            newArray.count <= array.count + 1,
            """
            ERROR: SwiftUI does not support increasing the navigation stack
            by more than one in a single update.
            OLD STACK:
            \(array)
            NEW STACK:
            \(newArray)
            """
        )
        array = newArray
    }
}

extension Stack where E: Equatable {
    
    /// Pops to the topmost (most recently pushed) screen in the stack
    /// equal to the given screen. If no screens are found,
    /// the screens array will be unchanged.
    /// - Parameter screen: The predicate indicating which screen to pop to.
    /// - Returns: A `Bool` indicating whether a matching screen was found.
    @discardableResult
    public mutating func popTo(_ screen: E) -> Bool {
        popTo(where: { $0 == screen })
    }
}

extension Stack where E: Identifiable {
    
    /// Pops to the topmost (most recently pushed) identifiable screen in the stack
    /// with the given ID. If no screens are found, the screens array will be unchanged.
    /// - Parameter id: The id of the screen to pop to.
    /// - Returns: A `Bool` indicating whether a matching screen was found.
    @discardableResult
    public mutating func popTo(id: E.ID) -> Bool {
        popTo(where: { $0.id == id })
    }
    
    /// Pops to the topmost (most recently pushed) identifiable screen in the stack
    /// matching the given screen. If no screens are found, the screens array
    /// will be unchanged.
    /// - Parameter screen: The screen to pop to.
    /// - Returns: A `Bool` indicating whether a matching screen was found.
    @discardableResult
    public mutating func popTo(_ screen: E) -> Bool {
        popTo(id: screen.id)
    }
}
