import json, logging

import azure.functions as func


def main(req: func.HttpRequest,
         cosmosDbDoc: func.DocumentList) -> func.HttpResponse:
    logging.info('Python HTTP trigger function "GetRating" processed a request.')

    if not cosmosDbDoc:
        return func.HttpResponse(
             f'Document with ratingId "{req.params.get("ratingId")}" not found.',
             status_code=404
        )

    # Return review document from Azure Cosmos DB as HTTP response
    return func.HttpResponse(
        cosmosDbDoc[0].to_json(),
        headers={
            'Content-type': 'application/json'
        })
