Here is how nectarine would implement the
[redux todo list example](http://redux.js.org/docs/basics/ExampleTodoList.html).

# Highlights

* The store exposes reducer like functions with `$set` and the related methods
* Every `$set` call results in the store being updated and thus an update for connected components
* `mapStateToProps` and `mapDispatchToProps` are combined into a single `mapProps`

# Entry Point

```js
// index.js
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
    return map({
      completed: _({initialValue: false})
      id: _({type: 'number', required: true})
      text: _({type: 'string', required: true})
    })
  },
  actions: {
    add: (text) => {
      let id = nextTodoId++
      this.slice.$key(id).$set({id, text})
    },
    toggle: (id) => {
      let todo = this.slice.$key(id)
      todo.completed.$set(not todo.completed)
    }
  }
})

export default todosSlice
```

```js
// store/visibility_filter_slice.js
import {createSlice} from 'nectarine'

const visibilityFilterSlice = createSlice({
  schema: (_) => {
    return _({initialValue: 'SHOW_ALL'})
  }
})

export default visibilityFilterSlice
```

```js
// store/index.js
import {createStore} from 'nectarine'
import todos from './todos_slice'
import visibilityFilter from './visibility_filter_slice'

const store = createStore({
  todos,
  visibilityFilterSlice
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
  return {
    todos: getVisibleTodos(store.todos.$getAll(), store.visibilityFilter.$get()),
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
  return {
    active: ownProps.filter === store.visibilityFilter.$get(),
    onClick: => store.visibilityFilter.$set(ownProps.filter),
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
