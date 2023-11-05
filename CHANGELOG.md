## 0.7.0
- New Dialogs feature! 100% customizable dialogs with customizable close button, background, and padding. 
  - New show dialog action.
  - New show dialog settings panel.
- Fix Edge Pins not syncing with server.
- Fix PageView triggers not executing.

## 0.6.0
- Embedded Canvases V1.
  - Embed canvases into layouts.
- Local Storage V1.
  - Store and persist data locally.
- Optimize JSON data to reduce data usage and storage by 80%.

## 0.5.2
- Remove dependency on Flutter.

## 0.5.1
- New shrink-wrap support for Buttons. Buttons can now resize based on the content inside them.
- New shrink-wrapping support for Slider, Switch, and Radio Button components.
- Fix ListView and PageView reverse scroll direction not enabled.
- Add `resolvedConstraint` override.

## 0.5.0
- Load APIs V1.
- Fix ExpansionTiles layout and functionality issues.
- Fix reactions not being modified.

## 0.4.1
- Add hover and splash color to dropdown node.
- Miscellaneous fixes.

## 0.4.0
- New `SetMapVariableAction` support for map variables.
- Support more conditions. 
  - `isEmpty`, `isNotEmpty`, `contains`
  - `isOdd`, `isEven`, `isNull`
- Add `remove` for list type variable.
- Remove deprecations and update formatting and documentation.

## 0.3.0
- Scrolling V1. Enable scrolling for Columns, Frames, and Canvases.
- Create list operations and index for List `SetVariableAction`.

## 0.2.0
- New simplified variables system. Variables passed into the CodelesslyWidget can now be referenced by name in the Codelessly Editor.

```
CodelesslyWidget(
  data: {
    'title': 'My Title',
    'productData': { // JSON Data
      'nested': {
        'json': {
          'path': 'Hey there!',
        }
      }
    }
  }
)

// Now you can access the variable directly in the Codelessly Editor.
${title} - 'My Title'

// Or, using the `data` object.
${data.title} - 'My Title'
${data.productData.nested.json.path} - 'Hey there!'
```

- Add `>=`, `<=`, and `== null` operators.
- Add data and variable support for dropdown component.
- Add Material 3 Switch UI component.
- Add Rounded Circular Progress Indicator component.
- Improve InkWell behavior. Show Inkwell effect on top of other widgets.
- Prototype implementation of custom widget embedding feature.

## 0.1.0
- Optimize SDK size by 90% by switching to SVG icons.
- Enable variables copy and paste.
- Enable conditions copy and paste.
- Fix canvas fill condition not working when there's only 1 fill.

## 0.0.8
- Text field and code-gen improvements.
- Add `showCounter` for input decoration.
- Fix text field counter text not working properly.
- Fix text field with incorrect sizing in codegen.

## 0.0.7
- Add support for Tabs.
- Add TextField support for variables.
- Add FAB support for variables.

## 0.0.6
- Update type support to support null values.

## 0.0.5
- Add improved Variables type support.

## 0.0.4
- Add Variables and Conditions support.

## 0.0.3
- Update SDK constraints.
- Update ReadMe.

## 0.0.2
- Upgrade to Flutter 3.10 and Dart 3.
- Add support for Listview and Pageview.
- Add support for API call action.
- Remove `ScrollLinkableMixin`.
- Add method to compare two font weights.
- Add method to generate a random ID.
- Update example.md.
- Update documentation.

## 0.0.1
- Initial Release.