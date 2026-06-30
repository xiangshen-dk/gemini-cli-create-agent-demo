# **Design Doc: ServiceNow Inventory Agent**

**Version:** 1.0  
**Date:** 2025-10-30  
**Author:** Gemini  
**Source API:** ServiceNow Table API (u_retail_products)

## **1. Overview**

This document outlines the design for a conversational ServiceNow inventory management agent built using the Google Agent Development Kit (ADK). The agent integrates with the ServiceNow Table API for the `u_retail_products` custom table, providing a natural language interface for managing retail product inventory through a chat-based interface.

## **2. Goals and Non-Goals**

### **Goals**

* Create a conversational agent that implements three core operations on the ServiceNow retail products table:
  1. `GET /api/now/table/u_retail_products`: Retrieves a list of retail products
  2. `POST /api/now/table/u_retail_products`: Creates a new retail product
  3. `GET /api/now/table/u_retail_products/{sys_id}`: Retrieves a specific retail product by system ID
* Provide secure and reliable integration with the ServiceNow Table API
* Leverage Google ADK for natural language understanding (NLU) and dialogue management
* Implement robust error handling and data validation using Pydantic models
* Package the agent with proper environment configuration
* Deploy to Google Cloud using Vertex AI and Google ADK CLI

### **Non-Goals**

* Support for operations not explicitly listed (e.g., PATCH, DELETE)
* A graphical user interface (GUI); the primary interface is conversational
* Management of other ServiceNow tables beyond u_retail_products

## **3. High-Level Architecture**

```
+----------------+     +---------------------+     +----------------------+
| User Interface |<--->|   Google ADK Agent  |<--->| ServiceNow Instance  |
| (Chat/Web UI)  |     | (NLU, Logic, State) |     | (u_retail_products)  |
+----------------+     +---------------------+     +----------------------+
                         |
                         |
                         v
+------------------------------------+
|      ServiceNowConnector           |
| (Handles API calls to ServiceNow)  |
+------------------------------------+
```

## **4. Detailed Design**

### **4.1. Data Model**

The agent uses a Pydantic model to validate and structure product data:

```python
class ProductInventory(BaseModel):
    sys_id: str                    # Unique system identifier
    sku: str                       # Product SKU (u_sku)
    name: str                      # Product name (u_name)
    quantity: Optional[str]        # Product quantity (u_quantity)
    category: Optional[str]        # Product category (u_category)
    brand: Optional[str]           # Product brand (u_brand)
    price: Optional[str]           # Product price (u_price)
    size: Optional[str]            # Product size (u_size)
    color: Optional[str]           # Product color (u_color)
    active: Optional[str]          # Active status (u_active)
```

### **4.2. Supported Operations**

#### **4.2.1. GET /api/now/table/u_retail_products (List Products)**

Retrieves a collection of retail product records with optional filtering.

**User Flow:**
1. **User:** "Show me all products" or "List products in the halloween category"
2. **Agent:** Parses the request and any filters
3. **Agent:** Calls ServiceNowConnector to make GET request
4. **Agent:** Returns formatted list of products with SKU, name, brand, category, price, size, color, and active status

**Example Response:**
A
```
Here are all the products in your inventory:

SKU	Name	Brand	Category	Price	Size	Color	Quantity
DEMO-VAMP-001	Classic Vampire Costume - L	SpookyStyle	halloween	$59.99	L	Black/Red	100
DEMO-WITCH-001	Witch Costume with Hat - M	SpookyStyle	halloween	$49.99	M	Black/Purple	20
```

#### **4.2.2. POST /api/now/table/u_retail_products (Create Product)**

Creates a new retail product record.

**User Flow:**
1. **User:** "Create a new product"
2. **Agent:** Gathers required fields (name, quantity)
3. **Agent:** Requests confirmation before creating
4. **User:** Confirms
5. **Agent:** Calls ServiceNowConnector to make POST request
6. **Agent:** Returns success message with new product details

**Required Fields:**
- `u_name`: Product name
- `u_quantity`: Product quantity

#### **4.2.3. GET /api/now/table/u_retail_products/{sys_id} (Get Product by ID)**

Retrieves details of a single product by its unique system ID.

**User Flow:**
1. **User:** "Get details for product with clasic cotton tee"
2. **Agent:** First, may need to find the sys_id for WIDGET-001 if not already known.
2. **Agent:** Calls ServiceNowConnector to make GET request with sys_id
3. **Agent:** Returns formatted product details

## **5. Implementation Details**

### **5.1. ServiceNowConnector**

The connector class handles all API interactions:
- Base URL: `{SERVICENOW_INSTANCE}/api/now/table/u_retail_products`
- Authentication: Basic Auth using username/password
- Headers: JSON content type and accept headers
- Error handling: Catches and reports request exceptions

### **5.2. Agent Tools**

Three function tools are registered with the ADK agent:
1. `get_product_inventories_tool(customer: Optional[str])`: Lists products
2. `create_product_inventory_tool(product_id, name, quantity, customer)`: Creates product
3. `get_product_inventory_by_sys_id_tool(sys_id)`: Gets specific product

### **5.3. Environment Configuration**

Required environment variables:
- `SERVICENOW_INSTANCE`: ServiceNow instance URL
- `SERVICENOW_USERNAME`: API username
- `SERVICENOW_PASSWORD`: API password
- `GOOGLE_CLOUD_PROJECT`: GCP project ID
- `GOOGLE_CLOUD_LOCATION`: GCP region (e.g., us-central1)
- `GEMINI_MODEL`: Gemini model name (e.g., gemini-3.5-flash)
- `GOOGLE_GENAI_USE_VERTEXAI`: Set to 1 for Vertex AI

## **6. Security**

- **Authentication:** Basic authentication with ServiceNow credentials
- **Credentials Management:** Environment variables stored in .env file.
- **Least Privilege:** ServiceNow user should have minimal required permissions
- **Confirmation Required:** User confirmation required for all create operations
- **Input Validation:** Pydantic models validate all data structures

## **7. Testing**

Testing should cover:
1. **List Products:** Verify correct retrieval and formatting
2. **Create Product:** Test with valid and invalid data
3. **Get Product by ID:** Test with valid and invalid sys_ids
4. **Error Handling:** Test API failures and network errors
5. **Data Validation:** Test Pydantic model validation

## **8. Deployment**

The agent can be deployed using:
```bash
adk deploy servicenow_inventory_agent
```

Ensure all environment variables are properly configured before deployment.
