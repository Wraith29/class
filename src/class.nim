import macros

template static* {.pragma.}

macro class*(head, body: untyped): untyped =
  let typeName = head.strVal
  result = newStmtList()

  var attrs = newNimNode(nnkRecList)
  let typeDef = newNimNode(nnkTypeSection)
    .add(newNimNode(nnkTypeDef)
      .add(ident(typeName))
      .add(newEmptyNode())
      .add(newNimNode(nnkRefTy)
        .add(newNimNode(nnkObjectTy)
          .add(newEmptyNode())
          .add(newEmptyNode())
          .add(attrs)
        )
      )
    )

  result.add(typeDef)

  for statement in body.children:
    if statement.kind == nnkCall:
      case statement[1][0].kind:
      of nnkIdent:
        attrs.add(
          newNimNode(nnkIdentDefs)
            .add(ident(statement[0].strVal))
            .add(ident(statement[1][0].strVal))
            .add(newEmptyNode())
        )
      of nnkBracketExpr:
        attrs.add(
          newNimNode(nnkIdentDefs)
            .add(ident(statement[0].strVal))
            .add(newNimNode(nnkBracketExpr)
              .add(ident(statement[1][0][0].strVal))
              .add(ident(statement[1][0][1].strVal)))
            .add(newEmptyNode())
        )
      else: discard
    elif statement.kind in [nnkProcDef, nnkFuncDef]:
      var def = statement
      if def[4].kind == nnkEmpty:
        def[3][1][1] = ident(head.strVal)
      result.add(def)