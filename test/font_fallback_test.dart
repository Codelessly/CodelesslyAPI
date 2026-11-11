import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';
void main(){
 test('fallback families roundtrip without changing defaults',(){
  expect(const TextStyle().toJson(),isNot(contains('fontFamilyFallback')));
  const style=TextStyle(fontFamily:'JetBrains Mono',fontFamilyFallback:['Noto Sans Symbols 2']);
  expect(TextStyle.fromJson(style.toJson()),style);
  expect(style.merge(const TextStyle(fontSize:16)).fontFamilyFallback,['Noto Sans Symbols 2']);
  expect(style,const TextStyle(fontFamily:'JetBrains Mono',fontFamilyFallback:['Noto Sans Symbols 2']));
  expect(style,isNot(const TextStyle(fontFamily:'JetBrains Mono')));
 });
}
