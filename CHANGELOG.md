## 2.1.0

- New TextInputField features! This is the first batch of improvements to the TextInput component and includes the
  following:
    - Added Autofill Hints support.
    - Added Text Input Validator.
    - Added Text Input Formatter.
    - Added Submit Keyboard Action selector.

## 2.0.2

- Update external components with reactions.
- Add click and long click reactions to rectangle node.

## 2.0.0

- Update Checkbox shrinkwrap and padding sizing.
- Change default Stroke cap to none.
- Optimize node sorting algorithm.

## 1.8.0

- Custom Layout IDs support! Now you can give your CloudUIs a name which makes identifying them much easier.

## 1.7.0

- Teams v1 support.

## 1.6.0

- Initial CloudUI support for Layout Groups.
    - Display different layouts for different screen sizes.

## 1.5.0

- Fix text node not allowing actions.

## 1.4.0

- New StyleSheets support! Define common color and text styles.
- Update GridView `childAlignment` property. Minor refactor.
- Improve Edge Pins.
    - Fix edge pins not being saved.
    - Clamp edge pins to positive values in wrapping parent layouts.

## 1.3.0

- Remove Montserrat font.

## 1.2.0

- Implement isTrue and isFalse operators for conditions.
- Refactor operator filtering to use index if available.

## 1.1.0

- New AutoComplete support for Variables.
- Fix disable automatic padding from Frames with strokes.

## 1.0.0

- Official v1 release!
- Update triggers types.
- Fix integer functions crashing with NaN and infinite values.

## 0.8.0

- Codelessly Data support. Save and write data to Codelessly Cloud.
- New GridView widget.
- Codelessly Data Query Filters support. Sort and filter data.
- Variable improvements.
    - Include 'set' and 'replace' operations for list operations.
    - Add new ${value} predefined variable to expose internal node data. TextFields only for now.
    - Track internal value with new NodeProvider InheritedWidget per-widget.
- TextField improvements.
    - Add support for actions on prefix and suffix icons on text fields.
    - Fix set operation on map not showing input field.
    - Implement proper TextFieldModel minimum size computation.
    - Add support for TextInputType.numberWithOptions.
- JSON improvements.
    - Fix json variable controller highlighting.
    - Fix json syntax highlighting for storage operations.
    - Fix focus nodes for json variable input fields.
- List improvements.
    - Add insertAll option for list operations
    - Refactor insert list operation to use json input field.
- Add copy-paste and shortcuts support for actions.
- Add support for non-blocking actions.
- Implement option to enable/disable action.
- Add firebase queries support for grid view.
- Add support for number operations.

## 0.7.5

- Fix drag and drop insert to the edge of Accordion, Expansion Tile, ListView, and PageView.

## 0.7.3

- Migrate Variables and Conditions to use permissions model.
- TextField Improvements
    - Fix shrink-wrapping conflict with expands property.
    - Fix text field model not calculating text field height properly for shrink-wrapping.
    - Allow min lines and max lines input fields to clear.
    - Fix shrink-wrap height calculation being affected by isDense property.

## 0.7.1

- Implement safe area for canvases.
- Fix scroll physics and always scrollable option.

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

- New simplified variables system. Variables passed into the CodelesslyWidget can now be referenced by name in the
  Codelessly Editor.

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
