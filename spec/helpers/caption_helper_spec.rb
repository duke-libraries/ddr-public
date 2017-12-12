require 'rails_helper'
require 'webvtt'

RSpec.describe CaptionHelper do

  describe "#clean_cue_text" do
    context "cue text line has voice tags" do
      let(:line) { "<v Interviewer>Where did you go to school?</v>" }
      it "should return plain text with no tags" do
        expect(helper.clean_cue_text(line)).to eq("Where did you go to school?")
      end
    end
  end

  describe "#cue_lines" do
    context "cue has line breaks" do
      let(:cue_text) { "Really?\nYeah."}
      it "should split into array of lines" do
        expect(helper.cue_lines(cue_text)).to eq(["Really?","Yeah."])
      end
    end
    context "cue has no line breaks" do
      let(:cue_text) { "Good morning."}
      it "should yield a single-item array" do
        expect(helper.cue_lines(cue_text)).to eq(["Good morning."])
      end
    end
  end

  describe "#cue_speaker" do
    context "line has a name in a voice tag" do
      let(:line) { "<v Jane Doe III>Where did you go to school?</v>" }
      it "should return speaker name" do
        expect(helper.cue_speaker(line)).to eq("Jane Doe III")
      end
    end
    context "line has a voice tag but no name" do
      let(:line) { "<v>Where did you go to school?</v>" }
      it "should return a dash" do
        expect(helper.cue_speaker(line)).to eq("-")
      end
    end
  end

  describe "#display_time" do
    context "cue begins at timecode under an hour" do
      let(:cue_time_sec) { 155 }
      it "should display without hours or zero-padding" do
        expect(helper.display_time(cue_time_sec)).to eq("2:35")
      end
    end
    context "cue begins at timecode over an hour" do
      let(:cue_time_sec) { 3832 }
      it "should display the hours without zero-padding" do
        expect(helper.display_time(cue_time_sec)).to eq("1:03:52")
      end
    end
  end

  describe "#caption_text_from_vtt" do

    let(:vtt) { WebVTT::File.new( Rails.root.join('spec', 'fixtures','abcd1234.vtt') )}

    context "cues are standard with no voice tags or line breaks" do
      let(:cue_1) { double("cue", :text => 'First cue.') }
      let(:cue_2) { double("cue", :text => 'Second cue.') }
      let(:cue_3) { double("cue", :text => 'Third cue.') }

      before { allow(vtt).to receive(:cues) { [cue_1, cue_2, cue_3] } }
      it "should render the cues on one line separated by a space" do
        expect(helper.caption_text_from_vtt(vtt)).to eq("First cue. Second cue. Third cue. ")
      end
    end

    context "cues have voice tags with speaker identified" do
      let(:cue_1) { double("cue", :text => '<v Interviewer>What is your name?</v>') }
      let(:cue_2) { double("cue", :text => '<v Mary>My name is Mary.</v>') }

      before { allow(vtt).to receive(:cues) { [cue_1, cue_2] } }
      it "should render double linebreaks between clues prefaced by speaker" do
        expect(helper.caption_text_from_vtt(vtt)).to eq("Interviewer: What is your name? \n\nMary: My name is Mary. ")
      end
    end

    context "cues have blank voice tags" do
      let(:cue_1) { double("cue", :text => '<v>What is your name?</v>') }
      let(:cue_2) { double("cue", :text => '<v>My name is Mary.</v>') }

      before { allow(vtt).to receive(:cues) { [cue_1, cue_2] } }
      it "should render double linebreaks between clues prefaced by dash" do
        expect(helper.caption_text_from_vtt(vtt)).to eq("- What is your name? \n\n- My name is Mary. ")
      end
    end

  end

end
