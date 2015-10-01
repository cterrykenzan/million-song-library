(function () {
  'use strict';

  var data = require('./data.js');
  var _ = require('lodash');

  module.exports = {
    artistList: artistList,
    getArtist: getArtist,
    getArtistAlbums: getArtistAlbums,
  };

  function artistList(req, res) {
    res.json({artists: data.artists});
  }

  function getArtist(req, res) {

    var artistId = req.swagger.params.artistId.value;

    var artist = _.findWhere(data.artists, { artistId: artistId });

    res.json({
      artistId: artist.artistId,
      artist_mbid: artist.artist_mbid,
      artist_name: artist.artist_name,
      albums_list: artist.albums_list,
      link_to_image: artist.link_to_image,
      songs_list: artist.songs_list
    });
  }

  function getArtistAlbums(req, res) {

    var artistId = req.swagger.params.artistId.value;
    var artist = _.findWhere(data.artists, {artistId: artistId});

    var albums = [];
    for (var i = 0; i < artist.albums_list.length; i++) {
      for (var j = 0; j < data.albums.length; j++) {
        if (artist.albums_list[i] === data.albums[j].album_id) {
          var album = data.albums[j];

          albums.push({
            album_id: album.album_id,
            album_name: album.album_name,
            link_to_image: album.link_to_image,
            songs_list: album.songs_list,
            album_year: album.album_year,
          });
        }

      }
    }
    res.json({albums: albums});
  }

})();