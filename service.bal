import ballerina/http;

service /api on new http:Listener(9090) {

    // GET /api/assets - Retrieve all assets
    resource function get assets() returns Asset[] {
        return getAllAssets();
    }

    // GET /api/assets/[assetTag] - Retrieve single asset by tag
    resource function get assets/[string assetTag]() returns Asset|http:NotFound {
        Asset? asset = getAsset(assetTag);
        if asset is () {
            return <http:NotFound>{body: {message: string `Asset '${assetTag}' not found`}};
        }
        return asset;
    }

    // POST /api/assets - Create new asset
    resource function post assets(AssetPayload payload) returns http:Created|http:Conflict {
        Asset newAsset = {
            assetTag: payload.assetTag,
            name: payload.name,
            description: payload.description,
            institution: payload.institution,
            site: payload.site,
            status: payload.status,
            dateAcquired: payload.dateAcquired,
            components: payload.components,
            schedules: payload.schedules,
            workOrders: payload.workOrders
        };

        boolean added = addAsset(newAsset);
        if !added {
            return <http:Conflict>{body: {message: string `Asset '${payload.assetTag}' already exists`}};
        }
        return <http:Created>{body: newAsset};
    }

    // PUT /api/assets/[assetTag] - Update existing asset
    resource function put assets/[string assetTag](AssetPayload payload) returns Asset|http:NotFound|http:BadRequest {
        if assetTag != payload.assetTag {
            return <http:BadRequest>{body: {message: "URL tag does not match body key"}};
        }

        Asset updated = {
            assetTag: payload.assetTag,
            name: payload.name,
            description: payload.description,
            institution: payload.institution,
            site: payload.site,
            status: payload.status,
            dateAcquired: payload.dateAcquired,
            components: payload.components,
            schedules: payload.schedules,
            workOrders: payload.workOrders
        };

        boolean success = updateAsset(updated);
        if !success {
            return <http:NotFound>{body: {message: string `Asset '${assetTag}' not found`}};
        }
        return updated;
    }

    // DELETE /api/assets/[assetTag] - Remove asset
    resource function delete assets/[string assetTag]() returns http:Ok|http:NotFound {
        boolean removed = removeAsset(assetTag);
        if !removed {
            return <http:NotFound>{body: {message: string `Asset '${assetTag}' not found`}};
        }
        return <http:Ok>{body: {message: string `Asset '${assetTag}' deleted successfully`}};
    }
}
