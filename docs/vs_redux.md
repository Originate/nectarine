Here is how nectarine would implement the
[redux todo list example](http://redux.js.org/docs/basics/ExampleTodoList.html).

# Highlights

* The store exposes reducers at a high level with `$set` and its related methods
* Each `$set` call can be thought of as a `dispatch` as it triggers updates
* Actions are plain functions and can be used for encapsulation or to group getters or setters
* `mapStateToProps` and `mapDispatchToProps` are combined into a single `mapProps`

The following is the source code that would replace the entry point, action creators, reducers, and container components.
The presentational components would be the same.

# Entry Point

```js
import React from 'react'
import {render} from 'react-dom'
import {Provider} from 'nectarine'
import store from './store'
import App from './components/App'

render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById('root')
)
```

# Store

This replaces the `Action Creators` and `Reducers` sections

```js
// store/todos_slice.js
import {createSlice} from 'nectarine'

let nextTodoId = 0

const todosSlice = createSlice({
  schema: (_, map) => {
    list: map({
      completed: _({initialValue: false})
      id: _({type: 'number', allowNull: false})
      text: _({type: 'string', allowNull: false})
    })
  },
  actions: {
    add: (text) => {
      let id = nextTodoId++
      this.slice.list.$key(id).$set({id, text})
    },
    toggle: (id) => {
      let todo = this.slice.list.$key(id)
      todo.completed.$set(not todo.completed)
    }
  }
})

export default todosSlice
```

```js
// store/user_interface_slice.js
import {createSlice} from 'nectarine'

const userInterfaceSlice = createSlice({
  schema: (_, map) => {
    visibilityFilter: _({initialValue: 'SHOW_ALL'})
  }
})

export default userInterfaceSlice
```

```js
// store/index.js
import {createStore} from 'nectarine'
import todos from './todos_slice'
import userInterface from './user_interface_slice'

const store = createStore({
  todos,
  userInterface
})

export default store
```

# Container Components

```js
// containers/VisibleTodoList.js
import {connect} from 'nectarine'
import TodoList from '../components/TodoList'

const getVisibleTodos = (todos, filter) => {
  switch (filter) {
    case 'SHOW_ALL':
      return todos
    case 'SHOW_COMPLETED':
      return todos.filter(t => t.completed)
    case 'SHOW_ACTIVE':
      return todos.filter(t => !t.completed)
  }
}

const mapProps = (store) => {
  const filter = store.userInterface.visibilityFilter.$get()
  const todos = store.todos.list.$getAll()
  return {
    todos: getVisibleTodos(todos, filter),
    onTodoClick: (id) => store.todos.toggle(id)
  }
}

const VisibleTodoList = connect({
  component: TodoList,
  mapProps
})

export default VisibleTodoList
```

```js
// containers/FilterLink.js
import {connect} from 'nectarine'
import Link from '../components/Link'

const mapProps = (store, ownProps) => {
  const {visibilityFilter} = store.userInterface
  return {
    active: ownProps.filter === visibilityFilter.$get(),
    onClick: => visibilityFilter.$set(ownProps.filter),
  }
}

const FilterLink = connect({
  component: Link,
  mapProps
})

export default FilterLink
```

# Other Components

```js
// containers/AddTodo.js
import React from 'react'
import {connect} from 'nectarine'

let AddTodo = ({addTodo}) => {
  let input

  return (
    <div>
      <form onSubmit={e => {
        e.preventDefault()
        if (!input.value.trim()) {
          return
        }
        addTodo(input.value)
        input.value = ''
      }}>
        <input ref={node => {
          input = node
        }} />
        <button type="submit">
          Add Todo
        </button>
      </form>
    </div>
  )
}

AddTodo = connect({
  component: AddTodo
  mapProps: (store) => {
    return {
      addTodo: store.todos.add
    }
  }
})

export default AddTodo
```
