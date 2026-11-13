import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';
void main(){test('sustained waveform is optional and preserves defaults',(){
 expect(const PlaySoundAction().toJson(),isNot(contains('waveform')));
 final action=ActionDef.fromJson({'type':'playSound','operation':'start','waveform':'triangle'}, catalog: standardCatalog) as PlaySoundAction;
 expect(action.waveform,'triangle');expect(action.toJson()['waveform'],'triangle');
});}
