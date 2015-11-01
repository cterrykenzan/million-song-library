/**
 * album store
 * @param {request} request
 * @param {entityMapper} entityMapper
 * @param {AlbumInfoEntity} AlbumInfoEntity
 * @param {AlbumListEntity} AlbumListEntity
 * @param {$log} $log
 * @returns {*}
 */
export default function albumStore(request, entityMapper, AlbumInfoEntity, AlbumListEntity, $log) {
  'ngInject';

  const API_REQUEST_PATH = '/api/v1/catalogedge/';
  return {
    /**
     * fetch album from catalogue endpoint
     * @name albumStore#fetch
     * @param {string} albumId
     * @return {AlbumInfoEntity}
     */
    async fetch(albumId) {
      try {
        const response = await request.get(`${ API_REQUEST_PATH }album/${ albumId }`);
        return entityMapper(response.data, AlbumInfoEntity);
      } catch(error) {
        $log.error(error);
      }
    },

    /**
     * fetch all albums from catalogue endpoint
     * @name albumStore#fetchAll
     * @param {string} genre
     * @return {AlbumListEntity}
     */
    async fetchAll(genre) {
      try {
        const params = { params: { facets: genre } };
        const response = await request.get(`${ API_REQUEST_PATH }browse/album`, params);
        return entityMapper(response.data, AlbumListEntity);
      } catch(error) {
        $log.error(error);
      }
    },
  };
}
