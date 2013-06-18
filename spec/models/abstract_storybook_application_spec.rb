require 'spec_helper'

describe AbstractStorybookApplication do
  let(:storybook) { Factory(:storybook) }
  let(:storybook_json) {
    '{"Configurations":{"pageFlipSound":{"forward":"page-flip-sound.mp3","backward":"page-flip-sound.mp3"},"pageFlipTransitionDuration":null,"paragraphTextFadeDuration":null,"autoplayPageTurnDelay":null,"autoplayParagraphDelay":null,"homeMenuForPages":{"normalStateImage":"home-button.png","tappedStateImage":"home-button-over.png","position":[20,20]}},"Pages":[{"API":{"CCMoveTo":[{"actionTag":2,"duration":0,"position":[516,388]},{"actionTag":3,"duration":3,"position":[522,372]}],"CCScaleTo":[{"actionTag":1,"duration":0,"intensity":1}],"CCSequence":[],"CCDelayTime":[],"CCSpawn":[],"CCStorySwipeEnded":{"runAction":[{"runAfterSwipeNumber":1,"spriteTag":2,"actionTags":[3]}]},"CCStoryTouchableNode":{"nodes":[]},"CCSprites":[{"image":"https://fakes3.amazonaws.com/images/787/page11-bg-ipad.jpg","spriteTag":2,"position":[516.255735732449,387.9793814432966],"actions":[1,2]}]},"Page":{"settings":{"number":1},"text":{"paragraphs":[{"linesOfText":[{"text":"Lorem Ipsum Lorem Ipsum Lorem Ipsum","xOffset":318,"yOffset":139,"fontType":"arial.ttf","fontColor":[255,0,0],"fontHighlightColor":[255,0,0],"fontSize":25}],"highlightingTimes":[0],"voiceAudioFile":null},{"linesOfText":[{"text":"Noot Noot Noot Noot Noot Noot Pingu Pingu","xOffset":309,"yOffset":145,"fontType":"ComicSansMS.ttf","fontColor":[255,0,0],"fontHighlightColor":[255,0,0],"fontSize":25}],"highlightingTimes":[0],"voiceAudioFile":null}]}}},{"API":{"CCMoveTo":[{"actionTag":5,"duration":0,"position":[503,378]}],"CCScaleTo":[{"actionTag":4,"duration":0,"intensity":1}],"CCSequence":[],"CCDelayTime":[],"CCSpawn":[],"CCStorySwipeEnded":{"runAction":[]},"CCStoryTouchableNode":{"nodes":[]},"CCSprites":[{"image":"https://fakes3.amazonaws.com/images/786/page9-bg-ipad.jpg","spriteTag":3,"position":[502.9365035959409,378.2268041237107],"actions":[4,5]}]},"Page":{"settings":{"number":2},"text":{"paragraphs":[{"linesOfText":[{"text":"Lorem Ipsum Lorem Ipsum Lorem Ipsum","xOffset":307,"yOffset":216,"fontType":"arial.ttf","fontColor":[255,0,0],"fontHighlightColor":[255,0,0],"fontSize":25}],"highlightingTimes":[0],"voiceAudioFile":null},{"linesOfText":[{"text":"","fontType":"Arial.ttf","fontColor":[255,183,213],"fontHighlightColor":[255,0,0],"fontSize":25}],"highlightingTimes":[0],"voiceAudioFile":null}]}}}],"MainMenu":{"CCSprites":[{"image":"https://fakes3.amazonaws.com/images/785/page10-bg-ipad.jpg","spriteTag":1,"position":[502.37069649155956,386.34020618556167],"visible":true}],"fallingPhysicsSettings":{"plistfilename":"snowflake-main-menu.plist"},"MenuItems":[{"normalStateImage":"/assets/sprites/read_it_myself.png","tappedStateImage":"/assets/sprites/read_it_myself.png","storyMode":"readItMyself","position":[814,128]},{"normalStateImage":"/assets/sprites/read_to_me.png","tappedStateImage":"/assets/sprites/read_to_me.png","storyMode":"readToMe","position":[477,126]},{"normalStateImage":"/assets/sprites/auto_play.png","tappedStateImage":"/assets/sprites/auto_play.png","storyMode":"autoPlay","position":[158,120]}],"API":{}}}'
    }

  let(:processed_json_hash) {
        { "Configurations"=>{"pageFlipSound"=>{"forward"=>"page-flip-sound.mp3", "backward"=>"page-flip-sound.mp3"}, "pageFlipTransitionDuration"=>nil, "paragraphTextFadeDuration"=>nil, "autoplayPageTurnDelay"=>nil, "autoplayParagraphDelay"=>nil, "homeMenuForPages"=>{"normalStateImage"=>"home-button.png", "tappedStateImage"=>"home-button-over.png", "position"=>[20, 20]}}, "Pages"=>[{"API"=>{"CCMoveTo"=>[{"actionTag"=>2, "duration"=>0, "position"=>[516, 388]}, {"actionTag"=>3, "duration"=>3, "position"=>[522, 372]}], "CCScaleTo"=>[{"actionTag"=>1, "duration"=>0, "intensity"=>1}], "CCSequence"=>[], "CCDelayTime"=>[], "CCSpawn"=>[], "CCStorySwipeEnded"=>{"runAction"=>[{"runAfterSwipeNumber"=>1, "spriteTag"=>2, "actionTags"=>[3]}]}, "CCStoryTouchableNode"=>{"nodes"=>[]}, "CCSprites"=>[{"image"=>"random.jpg", "spriteTag"=>2, "position"=>[516.255735732449, 387.9793814432966], "actions"=>[1, 2]}]}, "Page"=>{"settings"=>{"number"=>1}, "text"=>{"paragraphs"=>[{"linesOfText"=>[{"text"=>"Lorem Ipsum Lorem Ipsum Lorem Ipsum", "xOffset"=>318, "yOffset"=>139, "fontType"=>"arial.ttf", "fontColor"=>[255, 0, 0], "fontHighlightColor"=>[255, 0, 0], "fontSize"=>25}], "highlightingTimes"=>[0], "voiceAudioFile"=>nil}, {"linesOfText"=>[{"text"=>"Noot Noot Noot Noot Noot Noot Pingu Pingu", "xOffset"=>309, "yOffset"=>145, "fontType"=>"ComicSansMS.ttf", "fontColor"=>[255, 0, 0], "fontHighlightColor"=>[255, 0, 0], "fontSize"=>25}], "highlightingTimes"=>[0], "voiceAudioFile"=>nil}]}}}, {"API"=>{"CCMoveTo"=>[{"actionTag"=>5, "duration"=>0, "position"=>[503, 378]}], "CCScaleTo"=>[{"actionTag"=>4, "duration"=>0, "intensity"=>1}], "CCSequence"=>[], "CCDelayTime"=>[], "CCSpawn"=>[], "CCStorySwipeEnded"=>{"runAction"=>[]}, "CCStoryTouchableNode"=>{"nodes"=>[]}, "CCSprites"=>[{"image"=>"random.jpg", "spriteTag"=>3, "position"=>[502.9365035959409, 378.2268041237107], "actions"=>[4, 5]}]}, "Page"=>{"settings"=>{"number"=>2}, "text"=>{"paragraphs"=>[{"linesOfText"=>[{"text"=>"Lorem Ipsum Lorem Ipsum Lorem Ipsum", "xOffset"=>307, "yOffset"=>216, "fontType"=>"arial.ttf", "fontColor"=>[255, 0, 0], "fontHighlightColor"=>[255, 0, 0], "fontSize"=>25}], "highlightingTimes"=>[0], "voiceAudioFile"=>nil}, {"linesOfText"=>[{"text"=>"", "fontType"=>"Arial.ttf", "fontColor"=>[255, 183, 213], "fontHighlightColor"=>[255, 0, 0], "fontSize"=>25}], "highlightingTimes"=>[0], "voiceAudioFile"=>nil}]}}}], "MainMenu"=>{"CCSprites"=>[{"image"=>"random.jpg", "spriteTag"=>1, "position"=>[502.37069649155956, 386.34020618556167], "visible"=>true}], "fallingPhysicsSettings"=>{"plistfilename"=>"snowflake-main-menu.plist"}, "MenuItems"=>[{"normalStateImage"=>"read_it_myself.png", "tappedStateImage"=>"read_it_myself.png", "storyMode"=>"readItMyself", "position"=>[814, 128]}, {"normalStateImage"=>"read_to_me.png", "tappedStateImage"=>"read_to_me.png", "storyMode"=>"readToMe", "position"=>[477, 126]}, {"normalStateImage"=>"auto_play.png", "tappedStateImage"=>"auto_play.png", "storyMode"=>"autoPlay", "position"=>[158, 120]}], "API"=>{}}}
    }
  let(:storybook_application) { AbstractStorybookApplication.new(storybook, storybook_json, 'testing') }

  context '#download_files_and_sanitize_json' do
    it 'downloads remote files ' do
      storybook_application.stub(:fetch_file) { 'random.jpg' }
        expect(storybook_application.download_files_and_sanitize_json(ActiveSupport::JSON.decode(storybook_json))).to eq(processed_json_hash)
    end
  end

  context '#move_unused_files_out_of_compilation' do
    it 'moves system files out of compilation' do
      AbstractStorybookApplication.stub(:system_font_names).and_return(['arial.ttf', 'ComicSansMS.ttf', 'Verdana.ttf', 'CourierNew.ttf'])
      removal_paths = [
        File.join(AbstractStorybookApplication::CRUCIBLE_RESOURCES_DIR, 'Verdana.ttf'),
        File.join(AbstractStorybookApplication::CRUCIBLE_RESOURCES_DIR, 'CourierNew.ttf')
      ]

      FileUtils.should_receive(:mv).with(removal_paths, File.join(AbstractStorybookApplication::CRUCIBLE_RESOURCES_DIR, '..')).and_return(true)
      storybook_application.instance_variable_set(:@json_hash, processed_json_hash)
      storybook_application.move_unused_files_out_of_compilation
    end
  end

  context "#move_unused_files_to_resources" do
    it 'moves system files to resources' do
      AbstractStorybookApplication.stub(:system_font_names).and_return(['arial.ttf', 'ComicSansMS.ttf', 'Verdana.ttf', 'CourierNew.ttf'])
      removal_paths = [
        File.join(AbstractStorybookApplication::CRUCIBLE_RESOURCES_DIR, 'Verdana.ttf'),
        File.join(AbstractStorybookApplication::CRUCIBLE_RESOURCES_DIR, 'CourierNew.ttf')
      ]
      resources_paths = [
        File.join(AbstractStorybookApplication::CRUCIBLE_RESOURCES_DIR, '..', 'Verdana.ttf'),
        File.join(AbstractStorybookApplication::CRUCIBLE_RESOURCES_DIR, '..', 'CourierNew.ttf')
      ]
      FileUtils.should_receive(:mv).with(removal_paths, File.join(AbstractStorybookApplication::CRUCIBLE_RESOURCES_DIR, '..')).and_return(true)
      FileUtils.should_receive(:mv).with(resources_paths, File.join(AbstractStorybookApplication::CRUCIBLE_RESOURCES_DIR)).and_return(true)
      storybook_application.instance_variable_set(:@json_hash, processed_json_hash)
      storybook_application.move_unused_files_out_of_compilation
      storybook_application.move_unused_files_to_resources
    end
  end

  context '#cleanup' do
    it 'should remove transient files' do
      storybook_application.instance_variable_set(:@transient_files, ['foo', 'bar'])
      storybook_application.write_transient_file_names_for_deletion
      File.should_receive(:delete).with(*['foo', 'bar'])
      storybook_application.cleanup
    end
  end

  ['compile', 'upload_compiled_application', 'send_notification'].each do |meth|
    context "##{meth}" do
      it 'should raise error' do
        expect do
          storybook_application.send(meth.to_sym)
        end.to raise_error
      end
    end
  end
end
