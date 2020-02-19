import json, logging, requests, uuid
from datetime import datetime, timezone

import azure.functions as func


def main(req: func.HttpRequest,
         cosmosDbDoc: func.Out[func.Document]) -> func.HttpResponse:
    logging.info('Python HTTP trigger function "CreateRating" processed a request.')

    # Read request body
    req_body = None
    try:
        req_body = req.get_json()
    except ValueError:
        return func.HttpResponse(
             'Empty request body. Please pass a rating payload in the request body',
             status_code=400
        )

    # Validate both userId and productId by calling the existing API endpoints
    user_id = req_body.get('userId')
    product_id = req_body.get('productId')
    logging.info(f'user_id: {user_id}')
    logging.info(f'product_id: {product_id}')

    res1 = requests.get(f'https://serverlessohproduct.trafficmanager.net/api/GetProduct?productId={product_id}') # abstract domain in app settings
    if res1.status_code != 200:
        return func.HttpResponse(
             'Please pass a valid productId in request body',
             status_code=400
        )

    res2 = requests.get(f'https://serverlessohuser.trafficmanager.net/api/GetUser?userId={user_id}') # abstract domain in app settings
    if res2.status_code != 200:
        return func.HttpResponse(
             'Please pass a valid userId in request body',
             status_code=400
        )

    # Validate that the rating field is an integer from 0 to 5
    rating = req_body.get('rating')
    if not (isinstance(rating, int) and rating >= 0 and rating <= 5):
        return func.HttpResponse(
             'Please pass a valid rating in request body. Valid rating is integer between 0 and 5 inclusive',
             status_code=400
        )

    # Add properties id with a GUID value and timestamp with the current UTC date time
    review_doc = {
        'id': str(uuid.uuid4()),
        'timestamp': str(datetime.now(timezone.utc)),
        'userId': user_id,
        'productId': product_id,
        'locationName': req_body.get('locationName'),
        'rating': rating,
        'userNotes': req_body.get('userNotes')
    }

    # Write doc to Azure Cosmos DB
    cosmosDbDoc.set(func.Document.from_dict(review_doc))
    # cosmosDbDoc.set(review_doc)

    # Return the entire review JSON payload with the newly created id and timestamp
    return func.HttpResponse(
        json.dumps(review_doc),
        headers={
            'Content-type': 'application/json'
        })
