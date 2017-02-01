require! {
  './slice': Slice
}


create-slice = ({schema, actions}) ->
  new Slice {schema, actions}


module.exports = create-slice
