#
#
#            Nim's Runtime Library
#        (c) Copyright 2015 Andreas Rumpf
#
#    See the file "LICENSE.txt", included in this
#    distribution, for details about the copyright.
#

import
  sdl, smpeg

when defined(windows):
  const
    MixerLibName = "SDL_mixer.dll"
elif defined(macosx):
  const
    MixerLibName = "libSDL_mixer-1.2.0.dylib"
else:
  const
    MixerLibName = "libSDL_mixer.so"
const
  MAJOR_VERSION* = 1
  MINOR_VERSION* = 2
  PATCHLEVEL* = 7    # Backwards compatibility

  CHANNELS* = 8           # Good default values for a PC soundcard
  DEFAULT_FREQUENCY* = 22050

when defined(IA32):
  const
    DEFAULT_FORMAT* = AUDIO_S16LSB
else:
  const
    DEFAULT_FORMAT* = AUDIO_S16MSB
const
  DEFAULT_CHANNELS* = 2
  MAX_VOLUME* = 128       # Volume of a chunk
  PATH_MAX* = 255             # mikmod.h constants
                              #*
                              #  * Library version
                              #  *
  LIBMIKMOD_VERSION_MAJOR* = 3
  LIBMIKMOD_VERSION_MINOR* = 1
  LIBMIKMOD_REVISION* = 8
  LIBMIKMOD_VERSION* = ((LIBMIKMOD_VERSION_MAJOR shl 16) or
      (LIBMIKMOD_VERSION_MINOR shl 8) or (LIBMIKMOD_REVISION))

type                          #music_cmd.h types
  PMusicCMD* = ptr MusicCMD
  MusicCMD*{.final.} = object  #wavestream.h types
    filename*: array[0..PATH_MAX - 1, char]
    cmd*: array[0..PATH_MAX - 1, char]
    pid*: TSYS_ThreadHandle

  PWAVStream* = ptr WAVStream
  WAVStream*{.final.} = object  #playmidi.h types
    wavefp*: pointer
    start*: int32
    stop*: int32
    cvt*: TAudioCVT

  PMidiEvent* = ptr MidiEvent
  MidiEvent*{.final.} = object
    time*: int32
    channel*: byte
    typ*: byte
    a*: byte
    b*: byte

  PMidiSong* = ptr MidiSong
  MidiSong*{.final.} = object  #music_ogg.h types
    samples*: int32
    events*: PMidiEvent

  POGG_Music* = ptr OGG_Music
  OGG_Music*{.final.} = object  # mikmod.h types
                                 #*
                                 #  * Error codes
                                 #  *
    playing*: int32
    volume*: int32              #vf: OggVorbis_File;
    section*: int32
    cvt*: TAudioCVT
    lenAvailable*: int32
    sndAvailable*: pointer

  ErrorEnum* = enum
    MMERR_OPENING_FILE, MMERR_OUT_OF_MEMORY, MMERR_DYNAMIC_LINKING,
    MMERR_SAMPLE_TOO_BIG, MMERR_OUT_OF_HANDLES, MMERR_UNKNOWN_WAVE_TYPE,
    MMERR_LOADING_PATTERN, MMERR_LOADING_TRACK, MMERR_LOADING_HEADER,
    MMERR_LOADING_SAMPLEINFO, MMERR_NOT_A_MODULE, MMERR_NOT_A_STREAM,
    MMERR_MED_SYNTHSAMPLES, MMERR_ITPACK_INVALID_DATA, MMERR_DETECTING_DEVICE,
    MMERR_INVALID_DEVICE, MMERR_INITIALIZING_MIXER, MMERR_OPENING_AUDIO,
    MMERR_8BIT_ONLY, MMERR_16BIT_ONLY, MMERR_STEREO_ONLY, MMERR_ULAW,
    MMERR_NON_BLOCK, MMERR_AF_AUDIO_PORT, MMERR_AIX_CONFIG_INIT,
    MMERR_AIX_CONFIG_CONTROL, MMERR_AIX_CONFIG_START, MMERR_GUS_SETTINGS,
    MMERR_GUS_RESET, MMERR_GUS_TIMER, MMERR_HP_SETSAMPLESIZE, MMERR_HP_SETSPEED,
    MMERR_HP_CHANNELS, MMERR_HP_AUDIO_OUTPUT, MMERR_HP_AUDIO_DESC,
    MMERR_HP_BUFFERSIZE, MMERR_OSS_SETFRAGMENT, MMERR_OSS_SETSAMPLESIZE,
    MMERR_OSS_SETSTEREO, MMERR_OSS_SETSPEED, MMERR_SGI_SPEED, MMERR_SGI_16BIT,
    MMERR_SGI_8BIT, MMERR_SGI_STEREO, MMERR_SGI_MONO, MMERR_SUN_INIT,
    MMERR_OS2_MIXSETUP, MMERR_OS2_SEMAPHORE, MMERR_OS2_TIMER, MMERR_OS2_THREAD,
    MMERR_DS_PRIORITY, MMERR_DS_BUFFER, MMERR_DS_FORMAT, MMERR_DS_NOTIFY,
    MMERR_DS_EVENT, MMERR_DS_THREAD, MMERR_DS_UPDATE, MMERR_WINMM_HANDLE,
    MMERR_WINMM_ALLOCATED, MMERR_WINMM_DEVICEID, MMERR_WINMM_FORMAT,
    MMERR_WINMM_UNKNOWN, MMERR_MAC_SPEED, MMERR_MAC_START, MMERR_MAX
  PMODULE* = ptr MODULE
  MODULE*{.final.} = object
  PUNIMOD* = ptr UNIMOD
  UNIMOD* = MODULE          #SDL_mixer.h types
                              # The internal format for an audio chunk
  PChunk* = ptr Chunk
  Chunk*{.final.} = object
    allocated*: cint
    abuf*: pointer
    alen*: uint32
    volume*: byte            # Per-sample volume, 0-128

  Fading* = enum
    MIX_NO_FADING, MIX_FADING_OUT, MIX_FADING_IN
  MusicType* = enum
    MUS_NONE, MUS_CMD, MUS_WAV, MUS_MOD, MUS_MID, MUS_OGG, MUS_MP3
  PMusic* = ptr Music
  Music*{.final.} = object  # The internal format for a music chunk interpreted via mikmod
    mixtype*: MusicType      # other fields are not aviable
                              #    data : MusicUnion;
                              #    fading : TMix_Fading;
                              #    fade_volume : integer;
                              #    fade_step : integer;
                              #    fade_steps : integer;
                              #    error : integer;

  MixFunction* = proc (udata, stream: pointer, length: cint): pointer{.
      cdecl.} # This macro can be used to fill a version structure with the compile-time
              #  version of the SDL_mixer library.
{.deprecated: [TMusicCMD: MusicCMD, TWAVStream: WAVStream, TMidiEvent: MidiEvent,
              TMidiSong: MidiSong, TOGG_Music: OGG_Music, TErrorEnum: ErrorEnum,
              TMODULE: MODULE, TUNIMOD: UNIMOD, TChunk: Chunk, TFading: Fading,
              TMusicType: MusicType, TMusic: Music, TMixFunction: MixFunction].}

proc version*(x: var sdl.Version)
  # This function gets the version of the dynamically linked SDL_mixer library.
  #     It should NOT be used to fill a version structure, instead you should use the
  #     SDL_MIXER_VERSION() macro.
proc linkedVersion*(): sdl.Pversion{.cdecl, importc: "Mix_Linked_Version",
                                      dynlib: MixerLibName.}
  # Open the mixer with a certain audio format
proc openAudio*(frequency: cint, format: uint16, channels: cint,
                    chunksize: cint): cint{.cdecl, importc: "Mix_OpenAudio",
    dynlib: MixerLibName.}
  # Dynamically change the number of channels managed by the mixer.
  #   If decreasing the number of channels, the upper channels are
  #   stopped.
  #   This function returns the new number of allocated channels.
  #
proc allocateChannels*(numchannels: cint): cint{.cdecl,
    importc: "Mix_AllocateChannels", dynlib: MixerLibName.}
  # Find out what the actual audio device parameters are.
  #   This function returns 1 if the audio has been opened, 0 otherwise.
  #
proc querySpec*(frequency: var cint, format: var uint16, channels: var cint): cint{.
    cdecl, importc: "Mix_QuerySpec", dynlib: MixerLibName.}
  # Load a wave file or a music (.mod .s3m .it .xm) file
proc loadWAV_RW*(src: PRWops, freesrc: cint): PChunk{.cdecl,
    importc: "Mix_LoadWAV_RW", dynlib: MixerLibName.}
proc loadWAV*(filename: cstring): PChunk
proc loadMUS*(filename: cstring): PMusic{.cdecl, importc: "Mix_LoadMUS",
    dynlib: MixerLibName.}
  # Load a wave file of the mixer format from a memory buffer
proc quickLoadWAV*(mem: pointer): PChunk{.cdecl,
    importc: "Mix_QuickLoad_WAV", dynlib: MixerLibName.}
  # Free an audio chunk previously loaded
proc freeChunk*(chunk: PChunk){.cdecl, importc: "Mix_FreeChunk",
                                        dynlib: MixerLibName.}
proc freeMusic*(music: PMusic){.cdecl, importc: "Mix_FreeMusic",
                                        dynlib: MixerLibName.}
  # Find out the music format of a mixer music, or the currently playing
  #   music, if 'music' is NULL.
proc getMusicType*(music: PMusic): MusicType{.cdecl,
    importc: "Mix_GetMusicType", dynlib: MixerLibName.}
  # Set a function that is called after all mixing is performed.
  #   This can be used to provide real-time visual display of the audio stream
  #   or add a custom mixer filter for the stream data.
  #
proc setPostMix*(mixFunc: MixFunction, arg: pointer){.cdecl,
    importc: "Mix_SetPostMix", dynlib: MixerLibName.}
  # Add your own music player or additional mixer function.
  #   If 'mix_func' is NULL, the default music player is re-enabled.
  #
proc hookMusic*(mixFunc: MixFunction, arg: pointer){.cdecl,
    importc: "Mix_HookMusic", dynlib: MixerLibName.}
  # Add your own callback when the music has finished playing.
  #
proc hookMusicFinished*(musicFinished: pointer){.cdecl,
    importc: "Mix_HookMusicFinished", dynlib: MixerLibName.}
  # Get a pointer to the user data for the current music hook
proc getMusicHookData*(): pointer{.cdecl, importc: "Mix_GetMusicHookData",
                                       dynlib: MixerLibName.}
  #* Add your own callback when a channel has finished playing. NULL
  # * to disable callback.*
type
  ChannelFinished* = proc (channel: cint){.cdecl.}
{.deprecated: [TChannelFinished: ChannelFinished].}

proc channelFinished*(channelFinished: ChannelFinished){.cdecl,
    importc: "Mix_ChannelFinished", dynlib: MixerLibName.}
const
  CHANNEL_POST* = - 2

type
  TEffectFunc* = proc (chan: cint, stream: pointer, length: cint,
                       udata: pointer): pointer{.cdecl.}
  TEffectDone* = proc (chan: cint, udata: pointer): pointer{.cdecl.}
proc registerEffect*(chan: cint, f: TEffectFunc, d: TEffectDone,
                         arg: pointer): cint{.cdecl,
    importc: "Mix_RegisterEffect", dynlib: MixerLibName.}

proc unregisterEffect*(channel: cint, f: TEffectFunc): cint{.cdecl,
    importc: "Mix_UnregisterEffect", dynlib: MixerLibName.}

proc unregisterAllEffects*(channel: cint): cint{.cdecl,
    importc: "Mix_UnregisterAllEffects", dynlib: MixerLibName.}
const
  EFFECTSMAXSPEED* = "MIX_EFFECTSMAXSPEED"

proc setPanning*(channel: cint, left: byte, right: byte): cint{.cdecl,
    importc: "Mix_SetPanning", dynlib: MixerLibName.}

proc setPosition*(channel: cint, angle: int16, distance: byte): cint{.cdecl,
    importc: "Mix_SetPosition", dynlib: MixerLibName.}

proc setDistance*(channel: cint, distance: byte): cint{.cdecl,
    importc: "Mix_SetDistance", dynlib: MixerLibName.}

proc setReverseStereo*(channel: cint, flip: cint): cint{.cdecl,
    importc: "Mix_SetReverseStereo", dynlib: MixerLibName.}

proc reserveChannels*(num: cint): cint{.cdecl, importc: "Mix_ReserveChannels",
    dynlib: MixerLibName.}

proc groupChannel*(which: cint, tag: cint): cint{.cdecl,
    importc: "Mix_GroupChannel", dynlib: MixerLibName.}
proc groupChannels*(`from`: cint, `to`: cint, tag: cint): cint{.cdecl,
    importc: "Mix_GroupChannels", dynlib: MixerLibName.}
proc groupAvailable*(tag: cint): cint{.cdecl, importc: "Mix_GroupAvailable",
    dynlib: MixerLibName.}
proc groupCount*(tag: cint): cint{.cdecl, importc: "Mix_GroupCount",
                                     dynlib: MixerLibName.}
proc groupOldest*(tag: cint): cint{.cdecl, importc: "Mix_GroupOldest",
                                      dynlib: MixerLibName.}
proc groupNewer*(tag: cint): cint{.cdecl, importc: "Mix_GroupNewer",
                                     dynlib: MixerLibName.}
proc playChannelTimed*(channel: cint, chunk: PChunk, loops: cint,
                           ticks: cint): cint{.cdecl,
    importc: "Mix_PlayChannelTimed", dynlib: MixerLibName.}
proc playChannel*(channel: cint, chunk: PChunk, loops: cint): cint
proc playMusic*(music: PMusic, loops: cint): cint{.cdecl,
    importc: "Mix_PlayMusic", dynlib: MixerLibName.}
proc fadeInMusic*(music: PMusic, loops: cint, ms: cint): cint{.cdecl,
    importc: "Mix_FadeInMusic", dynlib: MixerLibName.}
proc fadeInChannelTimed*(channel: cint, chunk: PChunk, loops: cint,
                             ms: cint, ticks: cint): cint{.cdecl,
    importc: "Mix_FadeInChannelTimed", dynlib: MixerLibName.}
proc fadeInChannel*(channel: cint, chunk: PChunk, loops: cint, ms: cint): cint

proc volume*(channel: cint, volume: cint): cint{.cdecl, importc: "Mix_Volume",
    dynlib: MixerLibName.}
proc volumeChunk*(chunk: PChunk, volume: cint): cint{.cdecl,
    importc: "Mix_VolumeChunk", dynlib: MixerLibName.}
proc volumeMusic*(volume: cint): cint{.cdecl, importc: "Mix_VolumeMusic",
    dynlib: MixerLibName.}

proc haltChannel*(channel: cint): cint{.cdecl, importc: "Mix_HaltChannel",
    dynlib: MixerLibName.}
proc haltGroup*(tag: cint): cint{.cdecl, importc: "Mix_HaltGroup",
                                    dynlib: MixerLibName.}
proc haltMusic*(): cint{.cdecl, importc: "Mix_HaltMusic",
                            dynlib: MixerLibName.}
  # Change the expiration delay for a particular channel.
  #   The sample will stop playing after the 'ticks' milliseconds have elapsed,
  #   or remove the expiration if 'ticks' is -1
  #
proc expireChannel*(channel: cint, ticks: cint): cint{.cdecl,
    importc: "Mix_ExpireChannel", dynlib: MixerLibName.}
  # Halt a channel, fading it out progressively till it's silent
  #   The ms parameter indicates the number of milliseconds the fading
  #   will take.
  #
proc fadeOutChannel*(which: cint, ms: cint): cint{.cdecl,
    importc: "Mix_FadeOutChannel", dynlib: MixerLibName.}
proc fadeOutGroup*(tag: cint, ms: cint): cint{.cdecl,
    importc: "Mix_FadeOutGroup", dynlib: MixerLibName.}
proc fadeOutMusic*(ms: cint): cint{.cdecl, importc: "Mix_FadeOutMusic",
                                      dynlib: MixerLibName.}
  # Query the fading status of a channel
proc fadingMusic*(): Fading{.cdecl, importc: "Mix_FadingMusic",
                                      dynlib: MixerLibName.}
proc fadingChannel*(which: cint): Fading{.cdecl,
    importc: "Mix_FadingChannel", dynlib: MixerLibName.}

proc pause*(channel: cint){.cdecl, importc: "Mix_Pause", dynlib: MixerLibName.}
proc resume*(channel: cint){.cdecl, importc: "Mix_Resume",
                                dynlib: MixerLibName.}
proc paused*(channel: cint): cint{.cdecl, importc: "Mix_Paused",
                                     dynlib: MixerLibName.}

proc pauseMusic*(){.cdecl, importc: "Mix_PauseMusic", dynlib: MixerLibName.}
proc resumeMusic*(){.cdecl, importc: "Mix_ResumeMusic", dynlib: MixerLibName.}
proc rewindMusic*(){.cdecl, importc: "Mix_RewindMusic", dynlib: MixerLibName.}
proc pausedMusic*(): cint{.cdecl, importc: "Mix_PausedMusic",
                              dynlib: MixerLibName.}

proc setMusicPosition*(position: float64): cint{.cdecl,
    importc: "Mix_SetMusicPosition", dynlib: MixerLibName.}

proc playing*(channel: cint): cint{.cdecl, importc: "Mix_Playing",
                                      dynlib: MixerLibName.}
proc playingMusic*(): cint{.cdecl, importc: "Mix_PlayingMusic",
                               dynlib: MixerLibName.}

proc setMusicCMD*(command: cstring): cint{.cdecl, importc: "Mix_SetMusicCMD",
    dynlib: MixerLibName.}

proc setSynchroValue*(value: cint): cint{.cdecl,
    importc: "Mix_SetSynchroValue", dynlib: MixerLibName.}
proc getSynchroValue*(): cint{.cdecl, importc: "Mix_GetSynchroValue",
                                  dynlib: MixerLibName.}

proc getChunk*(channel: cint): PChunk{.cdecl, importc: "Mix_GetChunk",
    dynlib: MixerLibName.}

proc closeAudio*(){.cdecl, importc: "Mix_CloseAudio", dynlib: MixerLibName.}

proc version(x: var sdl.Version) =
  x.major = MAJOR_VERSION
  x.minor = MINOR_VERSION
  x.patch = PATCHLEVEL

proc loadWAV(filename: cstring): PChunk =
  result = loadWAV_RW(rWFromFile(filename, "rb"), 1)

proc playChannel(channel: cint, chunk: PChunk, loops: cint): cint =
  result = playChannelTimed(channel, chunk, loops, - 1)

proc fadeInChannel(channel: cint, chunk: PChunk, loops: cint, ms: cint): cint =
  result = fadeInChannelTimed(channel, chunk, loops, ms, - 1)

