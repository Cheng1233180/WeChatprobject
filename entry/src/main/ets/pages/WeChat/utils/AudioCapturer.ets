import { audio } from "@kit.AudioKit";
import { fileIo } from "@kit.CoreFileKit";


class Options{
  offset?:number;
  length?:number;
}

export default class AudioCapture{
  static audioCapturer:audio.AudioCapturer
  static audioStreamInfo:audio.AudioStreamInfo={
    samplingRate:audio.AudioSamplingRate.SAMPLE_RATE_48000,
    channels:audio.AudioChannel.CHANNEL_2,
    sampleFormat:audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
    encodingType:audio.AudioEncodingType.ENCODING_TYPE_RAW


  }

  static audioCapturerInfo:audio.AudioCapturerInfo={
    source:audio.SourceType.SOURCE_TYPE_MIC,
    capturerFlags:0
  }
  static audioCapturerOptions:audio.AudioCapturerOptions={
    streamInfo:AudioCapture.audioStreamInfo,
    capturerInfo:AudioCapture.audioCapturerInfo
  }

  static recordIng:boolean=false

  static async init(){

    AudioCapture.audioCapturer=await audio.createAudioCapturer(AudioCapture.audioCapturerOptions)

    // AlertDialog.show({
    //   message:JSON.stringify(AudioCapture.audioCapturer)
    // })
  }

  static async start(filePath:string){
    try {
      if (!AudioCapture.audioCapturer) {
        return
      }

      let file=fileIo.openSync(filePath,fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
      let fd=file.fd
      let bufferSize:number=fileIo.statSync(fd).size

      AudioCapture.recordIng=true

      await AudioCapture.audioCapturer.start()

      while (AudioCapture.recordIng){

        let size=await AudioCapture.audioCapturer.getBufferSize()
        let buffer=await AudioCapture.audioCapturer.read(size,true)

        if (buffer) {
          let options:Options={
            offset:bufferSize,
            length:buffer.byteLength
          }
          fileIo.writeSync(file.fd,buffer,options)
          bufferSize+=buffer.byteLength
        }

      }

    } catch (e) {
      console.log(e)
    }
  }


    static stop(){
      if (AudioCapture.audioCapturer) {
        AudioCapture.audioCapturer.stop()
        AudioCapture.recordIng=false

      }
    }

    static release(){
      if (AudioCapture.audioCapturer) {
        AudioCapture.audioCapturer.release()

      }
    }



}















