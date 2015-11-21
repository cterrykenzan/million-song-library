package io.swagger.client;

import org.jboss.resteasy.client.jaxrs.ResteasyClient;
import org.jboss.resteasy.client.jaxrs.ResteasyClientBuilder;
import org.jboss.resteasy.client.jaxrs.ResteasyWebTarget;

import javax.ws.rs.client.Entity;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

/**
 * Created by anram88 on 11/19/15.
 */
public class ArtistClient {

    private String baseUrl = "http://localhost:9000/msl";
    private ResteasyClient client;

    public ArtistClient() {
        client = new ResteasyClientBuilder().build();
    }

    public Response get (String id) {
        ResteasyWebTarget target = client.target(baseUrl + "/v1/catalogedge/");
        Response response = target
                .path("artist/" + id)
                .request()
                .get();
        if (response.getStatus() != 200) {
            throw new RuntimeException("Failed : HTTP error code : "
                    + response.getStatus());
        }
        return response;
    }

    public Response browse(String facets) {
        ResteasyWebTarget target;
        if (!facets.isEmpty()){
            target = client.target(baseUrl + "/v1/catalogedge/browse/artist?facets=" + facets);
        }else {
            target = client.target(baseUrl + "/v1/catalogedge/browse/artist");
        }
        Response response = target
                .request()
                .get();
        return response;
    }

    public Response addArtist (String artistId, String sessionToken) {
        ResteasyWebTarget target = client.target(baseUrl + "/v1/accountedge/users/mylibrary/addartist/" + artistId);

        Response response = target
                .request()
                .header("sessionToken", sessionToken)
                .put(Entity.entity(artistId, MediaType.APPLICATION_JSON));
        return response;
    }
}
