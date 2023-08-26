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