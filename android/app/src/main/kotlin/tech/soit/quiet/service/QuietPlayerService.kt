package tech.soit.quiet.service

import android.net.Uri
import android.os.Bundle
import android.support.v4.media.MediaBrowserCompat
import android.support.v4.media.MediaBrowserServiceCompat
import android.support.v4.media.MediaDescriptionCompat
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaControllerCompat
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import android.util.Log
import com.google.android.exoplayer2.ExoPlaybackException
import com.google.android.exoplayer2.ExoPlayerFactory
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.source.ExtractorMediaSource
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.upstream.cache.CacheDataSourceFactory
import com.google.android.exoplayer2.upstream.cache.LeastRecentlyUsedCacheEvictor
import com.google.android.exoplayer2.upstream.cache.SimpleCache
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import tech.soit.quiet.AppContext
import java.util.*

class QuietPlayerService : MediaBrowserServiceCompat() {

    companion object {

        const val TAG = "QuietPlayerService"

        const val MEDIA_ID_ROOT = "nico nico ni"

        private const val USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" +
                " (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/13.10586"

        private val cache = SimpleCache(AppContext.filesDir, LeastRecentlyUsedCacheEvictor(1000 * 1000 * 100))

    }

    private lateinit var session: MediaSessionCompat
    private lateinit var playbackState: PlaybackStateCompat


    private var _player: SimpleExoPlayer? = null

    private val player by lazy {
        ExoPlayerFactory
                .newSimpleInstance(this, DefaultTrackSelector()).also {
                    _player = it
                    initPlayer(it)
                }
    }


    override fun onCreate() {
        super.onCreate()
        playbackState = PlaybackStateCompat.Builder()
                .setState(PlaybackStateCompat.STATE_NONE, 0, 1f)
                .build()
        session = MediaSessionCompat(this, TAG)
        session.setCallback(sessionCallback)
        session.setFlags(MediaSessionCompat.FLAG_HANDLES_TRANSPORT_CONTROLS
                and MediaSessionCompat.FLAG_HANDLES_QUEUE_COMMANDS)
        session.setPlaybackState(playbackState)

        //connect media browser and media browser service
        sessionToken = session.sessionToken
    }

    override fun onDestroy() {
        session.release()
        super.onDestroy()
    }

    private fun buildSource(url: String): ExtractorMediaSource {
        return ExtractorMediaSource.Factory(
                CacheDataSourceFactory(cache, DefaultDataSourceFactory(AppContext, USER_AGENT)))
                .createMediaSource(Uri.parse(requireNotNull(url)))
    }


    private fun initPlayer(player: SimpleExoPlayer) {
        player.addListener(object : Player.DefaultEventListener() {
            override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
                when (playbackState) {
                    Player.STATE_BUFFERING -> {
                        session.setPlaybackState(PlaybackStateCompat.Builder()
                                .setState(PlaybackStateCompat.STATE_BUFFERING,
                                        player.currentPosition,
                                        1.0f)
                                .build())
                    }
                    Player.STATE_ENDED -> {
                        session.setPlaybackState(
                                PlaybackStateCompat.Builder()
                                        .setState(PlaybackStateCompat.STATE_STOPPED, player.currentPosition, 1f)
                                        .build()
                        )
                    }
                    Player.STATE_READY -> {
                        session.setPlaybackState(PlaybackStateCompat.Builder()
                                .setState(
                                        if (playWhenReady)
                                            PlaybackStateCompat.STATE_PLAYING
                                        else
                                            PlaybackStateCompat.STATE_PAUSED,
                                        player.currentPosition, 1f)
                                .build())
                    }
                }

            }

            override fun onPlayerError(error: ExoPlaybackException) {
                session.setPlaybackState(PlaybackStateCompat.Builder()
                        .setState(PlaybackStateCompat.STATE_ERROR, 0, 1f).build())
            }
        })

    }


    private val sessionCallback = object : MediaSessionCompat.Callback() {

        override fun onPlay() {
            Log.d(TAG, "onPlay ${playbackState.state}")

            if (playbackState.state == PlaybackStateCompat.STATE_PLAYING) {
                val mPlaybackState = PlaybackStateCompat.Builder()
                        .setState(PlaybackStateCompat.STATE_PAUSED, 0, 1.0f)
                        .build()
                session.setPlaybackState(mPlaybackState)
            }

        }

        override fun onPause() {
            Log.d(TAG, " onPause ${playbackState.state}")
        }

        override fun onPlayFromMediaId(mediaId: String, extras: Bundle?) {
            val item = Playlist.queue.find { it.description.mediaId == mediaId }
            if (item == null) {
                Log.e(TAG, "error to find media id :$mediaId")
                return
            }

        }

        override fun onSeekTo(pos: Long) {
            Log.d(TAG, "onSeekTo $pos")
        }

        override fun onSkipToNext() {
            Log.d(TAG, "onSkipToNext")
        }

        override fun onSkipToPrevious() {
            Log.d(TAG, "onSkipToPrevious")
        }

        override fun onPlayFromSearch(query: String?, extras: Bundle?) {
            Log.d(TAG, "onPlayFromSearch$query")
        }

        override fun onAddQueueItem(description: MediaDescriptionCompat?) {
            Log.d(TAG, "onAddQueueItem")

        }

        override fun onRemoveQueueItem(description: MediaDescriptionCompat?) {
            Log.d(TAG, "onRemoveQueueItem")
        }
    }

    override fun onLoadChildren(parentId: String, result: Result<MutableList<MediaBrowserCompat.MediaItem>>) {
        Log.d(TAG, "onLoadChildren$parentId")

        result.detach()

        val mediaMetadata = MediaMetadataCompat.Builder()
                .putString(MediaMetadataCompat.METADATA_KEY_MEDIA_ID, "12424")
                .putString(MediaMetadataCompat.METADATA_KEY_TITLE, "hello")
                .build()
        val mediaItems = ArrayList<MediaBrowserCompat.MediaItem>()

        mediaItems.add(MediaBrowserCompat.MediaItem(mediaMetadata.description,
                MediaBrowserCompat.MediaItem.FLAG_PLAYABLE))
        result.sendResult(mediaItems)

    }

    override fun onGetRoot(clientPackageName: String, clientUid: Int, rootHints: Bundle?): BrowserRoot? {
        return BrowserRoot(MEDIA_ID_ROOT, null)
    }


    object Playlist {


        fun insert(current: MediaSessionCompat.QueueItem?, item: MediaSessionCompat.QueueItem) {
            queue.add(queue.indexOf(current) + 1, item)
        }

        var token: String? = null

        var queue: MutableList<MediaSessionCompat.QueueItem> = ArrayList()

        var current: MediaSessionCompat.QueueItem? = null
    }

    class MediaControlChannel(
            private val channel: MethodChannel,
            private var controller: MediaControllerCompat
    ) : MethodChannel.MethodCallHandler {

        companion object {

            const val TAG = "MediaControlChannel"

            fun registerWith(registrar: PluginRegistry.Registrar, token: MediaSessionCompat.Token) {
                val methodChannel = MethodChannel(registrar.messenger(), "tech.soit.quiet/player")
                val channel = MediaControlChannel(methodChannel, MediaControllerCompat(registrar.context(), token))
                methodChannel.setMethodCallHandler(channel)
            }

            private fun convertMapToQueueItem(map: Map<String, String>): MediaSessionCompat.QueueItem {
                return MediaSessionCompat.QueueItem(
                        MediaDescriptionCompat.Builder()
                                .setTitle(map["title"])
                                .setSubtitle(map["subTitle"])
                                .setIconUri(Uri.parse(map["imageUrl"]))
                                .setMediaId(map["id"])
                                .setMediaUri(Uri.parse(map["url"]))
                                .build(),
                        map["id"]?.toLong()!!
                )
            }

        }

        private val controllerCallback = object : MediaControllerCompat.Callback() {

            override fun onPlaybackStateChanged(state: PlaybackStateCompat) {
                when (state.state) {
                    PlaybackStateCompat.STATE_NONE -> {
                        Log.d(TAG, "STATE_NONE")
                    }
                    PlaybackStateCompat.STATE_PAUSED -> {
                        Log.d(TAG, "STATE_PAUSED")
                    }
                    PlaybackStateCompat.STATE_PLAYING -> {
                        Log.d(TAG, "STATE_PLAYING")
                    }
                }
                channel.invokeMethod("onPlaybackStateChanged", state)
            }

            override fun onMetadataChanged(metadata: MediaMetadataCompat?) {
                channel.invokeMethod("onPlayingChanged", metadata?.description?.mediaId)
            }

            override fun onShuffleModeChanged(shuffleMode: Int) {

            }

            override fun onQueueChanged(queue: MutableList<MediaSessionCompat.QueueItem>?) {

            }

            override fun onRepeatModeChanged(repeatMode: Int) {

            }

        }

        private val transportControls get() = controller.transportControls

        override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
            when (call.method) {
                "setPlaylist" -> {
                    @Suppress("UNCHECKED_CAST")
                    val list = (call.arguments as List<Map<String, String>>)
                    Playlist.queue = list.asSequence().map { map -> convertMapToQueueItem(map) }.toMutableList()
                }
                "playNext" -> transportControls?.skipToNext()
                "playPrevious" -> transportControls?.skipToPrevious()
                "play" -> {
                    val payload = call.arguments
                    if (payload == null) {
                        transportControls?.play()
                    } else {
                        @Suppress("UNCHECKED_CAST")
                        val item = convertMapToQueueItem(payload as Map<String, String>)
                        if (Playlist.queue.indexOfFirst { it.queueId == item.queueId } == -1) {
                            Playlist.insert(Playlist.current, item)
                        }
                        transportControls?.playFromMediaId(item.queueId.toString(), null)
                    }
                }
                "pause" -> transportControls?.pause()
                "setPlayMode" -> {
                    val mode = call.arguments as Int
                    transportControls?.let { transportControls ->
                        when (mode) {
                            0 -> {//single
                                transportControls.setRepeatMode(PlaybackStateCompat.REPEAT_MODE_ONE)
                                transportControls.setShuffleMode(PlaybackStateCompat.SHUFFLE_MODE_NONE)
                            }
                            1 -> {//sequence
                                transportControls.setRepeatMode(PlaybackStateCompat.REPEAT_MODE_ALL)
                                transportControls.setShuffleMode(PlaybackStateCompat.SHUFFLE_MODE_NONE)
                            }
                            2 -> {//shuffle
                                transportControls.setRepeatMode(PlaybackStateCompat.REPEAT_MODE_ALL)
                                transportControls.setShuffleMode(PlaybackStateCompat.SHUFFLE_MODE_ALL)
                            }
                        }
                    }
                }
                "seekTo" -> {
                    transportControls?.seekTo((call.arguments as Number).toLong())
                }
                "setVolume" -> {
                    //TODO
                }
                else -> result.notImplemented()

            }
        }

    }


}