// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pt locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'pt';

  static String m0(artistName, albumName, albumId, sharedUserId) =>
      "The ${artistName}\'s album《${albumName}》: http://music.163.com/album/${albumId}/?userid=${sharedUserId} (From @NeteaseCouldMusic)";

  static String m1(value) => "Contagem de album: ${value}";

  static String m2(value) => "Data de criação ${value}";

  static String m3(value) => "Música ${value}";

  static String m4(value) => "Contagem de reproduções: ${value}";

  static String m5(username, title, playlistId, userId, shareUserId) =>
      "Lista de reprodução criada por ${username}「${title}」: http://music.163.com/playlist/${playlistId}/${userId}/?userid=${shareUserId} (From @NeteaseCouldMusic)";

  static String m6(value) => "Track count: ${value}";

  static String m7(value) => "Encontrar música ${value}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("Sobre"),
        "addToPlaylist": MessageLookupByLibrary.simpleMessage(
            "adicionar a lista de reprodução"),
        "addToPlaylistFailed": MessageLookupByLibrary.simpleMessage(
            "falha ao adicionar a lista de reprodução"),
        "addedToPlaylistSuccess": MessageLookupByLibrary.simpleMessage(
            "Adicionado a lista de reprodução com sucesso"),
        "album": MessageLookupByLibrary.simpleMessage("Album"),
        "albumShareContent": m0,
        "alreadyBuy": MessageLookupByLibrary.simpleMessage("Pago (comprado)"),
        "artistAlbumCount": m1,
        "artists": MessageLookupByLibrary.simpleMessage("Artistas"),
        "clearPlayHistory": MessageLookupByLibrary.simpleMessage(
            "Limpar histórico de reprodução"),
        "cloudMusic": MessageLookupByLibrary.simpleMessage("Espaço da nuvem"),
        "cloudMusicFileDropDescription": MessageLookupByLibrary.simpleMessage(
            "Solte seu arquivo de música aqui para fazer upload."),
        "cloudMusicUsage": MessageLookupByLibrary.simpleMessage("Uso da nuvem"),
        "collectionLike": MessageLookupByLibrary.simpleMessage("Coleções"),
        "copyRightOverlay": MessageLookupByLibrary.simpleMessage(
            "Usado apenas para estudo e pesquisa pessoal, usos comerciais e ilegais são proibidos"),
        "createdDate": m2,
        "createdSongList":
            MessageLookupByLibrary.simpleMessage("Lista de músicas criadas"),
        "currentPlaying": MessageLookupByLibrary.simpleMessage("Tocanto"),
        "dailyRecommend":
            MessageLookupByLibrary.simpleMessage("Recomendações díarias"),
        "dailyRecommendDescription": MessageLookupByLibrary.simpleMessage(
            "Recomendar diariamente músicas de Netease. Atualiza todos os dias às 06:00."),
        "delete": MessageLookupByLibrary.simpleMessage("apagar"),
        "discover": MessageLookupByLibrary.simpleMessage("Descobrir"),
        "duration": MessageLookupByLibrary.simpleMessage("Duração"),
        "errorNotLogin": MessageLookupByLibrary.simpleMessage(
            "Conectar uma conta primeiro."),
        "errorToFetchData":
            MessageLookupByLibrary.simpleMessage("erro ao buscar dados."),
        "events": MessageLookupByLibrary.simpleMessage("Eventos"),
        "failedToDelete":
            MessageLookupByLibrary.simpleMessage("falha ao apagar"),
        "failedToLoad":
            MessageLookupByLibrary.simpleMessage("Falha ao carregar"),
        "failedToPlayMusic":
            MessageLookupByLibrary.simpleMessage("falha ao reproduzir música"),
        "favoriteSongList":
            MessageLookupByLibrary.simpleMessage("Lista de músicas favoritas"),
        "follow": MessageLookupByLibrary.simpleMessage("Seguir"),
        "follower": MessageLookupByLibrary.simpleMessage("Seguidor"),
        "friends": MessageLookupByLibrary.simpleMessage("Amigos"),
        "functionDescription":
            MessageLookupByLibrary.simpleMessage("Descrição"),
        "hideCopyrightOverlay": MessageLookupByLibrary.simpleMessage(
            "Ocultar sobreposição de direitos autorais"),
        "keySpace": MessageLookupByLibrary.simpleMessage("Espaço"),
        "latestPlayHistory":
            MessageLookupByLibrary.simpleMessage("Histórico de reproduções"),
        "leaderboard":
            MessageLookupByLibrary.simpleMessage("Entre os melhores"),
        "library": MessageLookupByLibrary.simpleMessage("Biblioteca"),
        "likeMusic": MessageLookupByLibrary.simpleMessage("Como música"),
        "loading": MessageLookupByLibrary.simpleMessage("carregando..."),
        "localMusic": MessageLookupByLibrary.simpleMessage("Música local"),
        "loginViaQrCode":
            MessageLookupByLibrary.simpleMessage("Conectar via QR code"),
        "loginViaQrCodeWaitingConfirmDescription":
            MessageLookupByLibrary.simpleMessage(
                "Confirme a conexão via QR code no aplicativo para celular Netease cloud music"),
        "loginViaQrCodeWaitingScanDescription":
            MessageLookupByLibrary.simpleMessage(
                "Escanear QR code com o aplicativo para celular netEase cloud music"),
        "loginWithPhone":
            MessageLookupByLibrary.simpleMessage("conectar com celular"),
        "logout": MessageLookupByLibrary.simpleMessage("Desconectar conta"),
        "musicCountFormat": m3,
        "musicName": MessageLookupByLibrary.simpleMessage("Nome da música"),
        "my": MessageLookupByLibrary.simpleMessage("Meu"),
        "myDjs": MessageLookupByLibrary.simpleMessage("Dj"),
        "myMusic": MessageLookupByLibrary.simpleMessage("Minhas Músicas"),
        "nextStep": MessageLookupByLibrary.simpleMessage("próximo passo"),
        "noLyric": MessageLookupByLibrary.simpleMessage("Sem letras"),
        "noMusic": MessageLookupByLibrary.simpleMessage("sem músicas"),
        "noPlayHistory":
            MessageLookupByLibrary.simpleMessage("Sem histórico de reprodução"),
        "pause": MessageLookupByLibrary.simpleMessage("Pausar"),
        "personalFM": MessageLookupByLibrary.simpleMessage("FM personalizada"),
        "personalFmPlaying":
            MessageLookupByLibrary.simpleMessage("Tocando FM personalizada"),
        "personalProfile":
            MessageLookupByLibrary.simpleMessage("Perfil Pessoal"),
        "play": MessageLookupByLibrary.simpleMessage("Reproduzir"),
        "playAll": MessageLookupByLibrary.simpleMessage("Tocar tudo"),
        "playInNext": MessageLookupByLibrary.simpleMessage("Tocar na próxima"),
        "playOrPause":
            MessageLookupByLibrary.simpleMessage("Reproduzir/Pausar"),
        "playingList": MessageLookupByLibrary.simpleMessage("Tocando lista"),
        "playlist": MessageLookupByLibrary.simpleMessage("Lista de reprodução"),
        "playlistLoginDescription": MessageLookupByLibrary.simpleMessage(
            "conecte sua conta para descobrir suas listas de reprodução."),
        "playlistPlayCount": m4,
        "playlistShareContent": m5,
        "playlistTrackCount": m6,
        "pleaseInputPassword":
            MessageLookupByLibrary.simpleMessage("Por favor digite a senha"),
        "projectDescription": MessageLookupByLibrary.simpleMessage(
            "Projeto de código aberto https://github.com/boyan01/flutter-netease-music"),
        "qrCodeExpired":
            MessageLookupByLibrary.simpleMessage("QR code expirado"),
        "recommendForYou":
            MessageLookupByLibrary.simpleMessage("Recomendado para você"),
        "recommendPlayLists": MessageLookupByLibrary.simpleMessage(
            "Listas de reprodução recomendadas"),
        "search": MessageLookupByLibrary.simpleMessage("Pesquisar"),
        "searchHistory":
            MessageLookupByLibrary.simpleMessage("Histórico de pesquisa"),
        "searchMusicResultCount": m7,
        "searchPlaylistSongs":
            MessageLookupByLibrary.simpleMessage("Pesquisar músicas"),
        "selectRegionDiaCode":
            MessageLookupByLibrary.simpleMessage("Selecionar código de região"),
        "selectTheArtist":
            MessageLookupByLibrary.simpleMessage("Selecionar o artista"),
        "settings": MessageLookupByLibrary.simpleMessage("configurações"),
        "share": MessageLookupByLibrary.simpleMessage("Compartilhe"),
        "shareContentCopied": MessageLookupByLibrary.simpleMessage(
            "Copiado para a área de transferência."),
        "shortcuts": MessageLookupByLibrary.simpleMessage("Atalhos"),
        "showAllHotSongs": MessageLookupByLibrary.simpleMessage(
            "Mostrar todas as músicas quentes >"),
        "skipAccompaniment": MessageLookupByLibrary.simpleMessage(
            "Pule o acompanhamento ao reproduzir a lista de reprodução."),
        "skipLogin": MessageLookupByLibrary.simpleMessage("Não usar conta"),
        "skipToNext":
            MessageLookupByLibrary.simpleMessage("Pular para seguinte"),
        "skipToPrevious":
            MessageLookupByLibrary.simpleMessage("Pular para anterior"),
        "songs": MessageLookupByLibrary.simpleMessage("Músicas"),
        "subscribe": MessageLookupByLibrary.simpleMessage("Se inscreva"),
        "theme": MessageLookupByLibrary.simpleMessage("Tema"),
        "themeAuto": MessageLookupByLibrary.simpleMessage("Seguir o sistema"),
        "themeDark": MessageLookupByLibrary.simpleMessage("Escuro"),
        "themeLight": MessageLookupByLibrary.simpleMessage("Claro"),
        "tipsAutoRegisterIfUserNotExist":
            MessageLookupByLibrary.simpleMessage("未注册手机号登陆后将自动创建账号"),
        "todo": MessageLookupByLibrary.simpleMessage("TBD"),
        "topSongs": MessageLookupByLibrary.simpleMessage("Principais músicas"),
        "trackNoCopyright": MessageLookupByLibrary.simpleMessage(
            "Rastrear sem direitos autorais"),
        "volumeDown": MessageLookupByLibrary.simpleMessage("Diminuir volume"),
        "volumeUp": MessageLookupByLibrary.simpleMessage("Almentar volume")
      };
}
