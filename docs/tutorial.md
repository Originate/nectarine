# Tutorial

# Creating and using a store

```js
// store/user_session_slice.js
import {createSlice} from 'nectarine'

const userSessionSlice = createSlice({
  schema: (_) => {
    id: _,
    profile: {
      email: _,
      name: _
    }
  }
})

export default userSessionSlice
```

```js
// store/index.js
import {createStore} from 'nectarine'
import userSession from './user_session_slice'

const store = createStore({userSession})

export default store
```

The store object looks very similar to the schema.
However, all data is encapsulated and can only be retrieved and updated with special methods.

```js
store.userSession.id.$set('user1')
store.userSession.profile.email.$set('john.doe@example.com')
store.userSession.profile.name.$set('John Doe')

store.$get() // => {userSession: {id: 'user1', profile: {email: 'john.doe@example.com', name: 'John Doe'}}}
store.userSession.$get() // => {id: 'user1', profile: {email: 'john.doe@example.com', name: 'John Doe'}}
store.userSession.profile.$get() // => {email: 'john.doe@example.com', name: 'John Doe'}
store.userSession.profile.email.$get() // => 'john.doe@example.com'
```

You can set an object all at once, which is equivalent to calling `$set` on each child.

```js
store.userSession.$set({
  id: 'user1',
  profile: {
    email: 'john.doe@example.com',
    name: 'John Doe'
  }
})
// is equivalent to
store.userSession.id.$set('user1')
store.userSession.profile.$set({
  email: 'john.doe@example.com',
  name: 'John Doe'
})
// is equivalent to
store.userSession.id.$set('user1')
store.userSession.profile.email.$set('john.doe@example.com')
store.userSession.profile.name.$set('John Doe')
```

Each location in the store has three states: data, loading, and error (mirroring a promise).
Data can also be loaded with promises

```js
store.userSession.$fromPromise(api.login({username: 'johnDoe123', password: 'secret'}))

// Promise is pending
store.userSession.$get() // => throws because the data is loading
store.userSession.$isLoading() // => true
store.userSession.$getError() // => null

// Promise resolves with {id: 'user1', profile: {email: 'john.doe@example.com', name: 'John Doe'}}
store.userSession.$get() // => {id: 'user1', profile: {email: 'john.doe@example.com', name: 'John Doe'}}
store.userSession.$isLoading() // => false
store.userSession.$getError() // => null

// Promise rejects with Error('Invalid Credentials')
store.userSession.$get() // => throws because the data errored
store.userSession.$isLoading() // => false
store.userSession.$getError() // => Error('Invalid Credentials')
```

# Usage with React

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

```js
// containers/user_navigation.js
import {connect} from 'nectarine'
import UserNavigation from '../components/user_navigation'

const mapProps = (store) => {
  return {
    profile: store.userSession.profile.$get()
  }
}

export default connect({
  component: UserNavigation,
  mapProps
})
```
