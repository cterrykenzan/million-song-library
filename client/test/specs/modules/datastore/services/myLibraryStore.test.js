import datastoreModule from 'modules/datastore/module';

describe('myLibraryStore', () => {
  let myLibraryStore, request, entityMapper, MyLibraryEntity, StatusResponseEntity;

  beforeEach(() => {
    angular.mock.module(datastoreModule, ($provide) => {
      request = jasmine.createSpyObj('request', ['get', 'put']);
      entityMapper = jasmine.createSpy('entityMapper');

      $provide.value('request', request);
      $provide.value('entityMapper', entityMapper);
    });

    inject((_myLibraryStore_, _MyLibraryEntity_, _StatusResponseEntity_) => {
      myLibraryStore = _myLibraryStore_;
      MyLibraryEntity = _MyLibraryEntity_;
      StatusResponseEntity = _StatusResponseEntity_;
    });
  });

  describe('fetch', () => {
    const response = 'a_response';
    beforeEach(() => {
      request.get.and.returnValue({ data: response });
    });

    it('should request the list of songs', (done) => {
      (async () => {
        await myLibraryStore.fetch();
        expect(request.get).toHaveBeenCalledWith('/msl/v1/accountedge/users/mylibrary');
        done();
      })();
    });

    it('should map the response into a SongListEntity', (done) => {
      (async () => {
        await myLibraryStore.fetch();
        expect(entityMapper).toHaveBeenCalledWith(response, MyLibraryEntity);
        done();
      })();
    });
  });

  describe('addSong', () => {
    const SONG_ID = '2';
    const response = 'a_response';

    beforeEach(() => {
      request.put.and.returnValue({ data: response });
    });

    it('should make a put request to add the song to the library endpoint', (done) => {
      (async () => {
        await myLibraryStore.addSong(SONG_ID);
        const headers = { headers: { 'Content-Type': 'application/json' } };
        expect(request.put).toHaveBeenCalledWith(`/msl/v1/accountedge/users/mylibrary/addsong/${ SONG_ID }`, null, headers);
        done();
      })();
    });

    it('should map the response into a StatusResponseEntity', (done) => {
      (async () => {
        await myLibraryStore.addSong(SONG_ID);
        expect(entityMapper).toHaveBeenCalledWith(response, StatusResponseEntity);
        done();
      })();
    });
  });

  describe('addAlbum', () => {
    const ALBUM_ID = '2';
    const response = 'a_response';

    beforeEach(() => {
      request.put.and.returnValue({ data: response });
    });

    it('should make a put request to add the album to the library endpoint', (done) => {
      (async () => {
        await myLibraryStore.addAlbum(ALBUM_ID);
        const headers = { headers: { 'Content-Type': 'application/json' } };
        expect(request.put).toHaveBeenCalledWith(`/msl/v1/accountedge/users/mylibrary/addalbum/${ ALBUM_ID }`);
        done();
      })();
    });

    it('should map the response into a StatusResponnseEntity', (done) => {
      (async () => {
        await myLibraryStore.addAlbum(ALBUM_ID);
        expect(entityMapper).toHaveBeenCalledWith(response, StatusResponseEntity);
        done();
      })();
    });
  });
});
