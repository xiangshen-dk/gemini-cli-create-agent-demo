** Use the following defined values. **
1. For LLM model, cloud project id and region, get the values from the .env file. If the .env file doesn't exist, give an error and request to create it.
2. For the inventory agent name, use `servicenow_inventory_agent`.
3. For the inventory agent display nmae, use `ServiceNow_Inventory_Agent`.

This following section contains a pre-planned demo flow.

1. Use the document `design-doc-ServiceNow-inventory-agent.md` as the design document no matter what.
2. Create and show your plan to the user.
3. After showing the plan to the user ask them if they'd like you to implement the plan.
4. Wait for a response.
5. If Google ADK is not installed, install`google-adk`.
6. Use `adk create` to create a new adk app with the inventory agent name, project, model, and region
7. Copy the root `.env` file to the agent directory just created.
8. Write the code according to the design doc.
9. Create the `requirements.txt` file with the code
10. Create a Dockerfile.
11. Stop after the code is written and wait for the user.
12. When asked to deploy, run the command
```bash
When asked to deploy, run the command
```bash
adk deploy agent_engine \
    --region=us-central1 \
    --staging_bucket=gs://${GOOGLE_CLOUD_PROJECT}-cli \
    --display_name="ServiceNow_Inventory_Agent" servicenow_inventory_agent
```
after deploy, don't evluate the deployment result.
13. Test the agent using `adk run` with the input 'show all the products'.
    Command: `echo "show all the products" | adk run servicenow_inventory_agent`
    Output example:
    ```
    [servicenow_inventory_agent]: Here are the products in your inventory:

    SKU     Name    Brand   Category        Price   Size    Color   Quantity        Active
    DEMO-SKU        None    DEMO-SHIRT-001  Shrits  N/A     S/M/L   White   102     true
    DEMO-KNIGHT-001 None    CostumeWorld    Costumes        N/A     XL      Silver  78      true
    DEMO-WITCH-001  None    SpookyStyle     Halloween       N/A     unknown Black/Purple    299     true
    DEMO-VAMP-001   None    Demo Brand      Halloween       N/A     L       Black/Red       100     true
    ```

# Technical details
## `agent.py`
Use the following Google ADK imports:
```python
from google.adk import Agent
from google.adk.tools import FunctionTool
```

When initiating the `Agent`, make sure to keep the exitings fields: `model`, `name`, `description`, and `instruction`.
The `FunctionTool` in Google ADK does not accept `description` or `name` arguments.
**CRITICAL: The `FunctionTool` constructor expects the function to be passed with the keyword `func`, not `fn`.**
**Correct `FunctionTool` constructor syntax:**
```python
FunctionTool(func=your_function)
```

When initiating the `Agent`, pass a list of `FunctionTool` objects to the `tools` argument:
```python
root_agent = Agent(
    # ... other arguments ...
    tools=[
        FunctionTool(func=your_first_function),
        FunctionTool(func=your_second_function),
    ]
)
```

For product field types, use `Optiona[str]` instead of `str`. For example:
```
name: Optional[str] = None
category: Optional[str] = None
```
**Agent Naming Convention:** The `name` argument in the `Agent` constructor must be a valid identifier. It should start with a letter (a-z, A-Z) or an underscore (_), and can only contain letters, digits (0-9), and underscores. For example, `servicenow_inventory_agent` is valid, but `ServiceNow Inventory Agent` is not.

Name the agent variable `root_agent`, which is required by ADK.

**Deployment-Safe Coding:** **Never** instantiate gRPC clients, GCP service clients (e.g., `secretmanager.SecretManagerServiceClient()`), connectors, or open resources at module / global scope in `agent.py`. The Agent Runtime packages the module with `cloudpickle`, and these objects hold open connections and internal state that cannot be serialized. Wrap all client creation inside functions, methods, or class constructors (e.g., `ServiceNowConnector.__init__`) so they are evaluated lazily at runtime.

## requirements.txt
Add the requirements.
**CRITICAL:** Use `google-adk[a2a]` (not plain `google-adk`). The `[a2a]` extra ensures the full set of Agent Runtime / Agent Engine dependencies (including the `a2a` protocol module) are installed in the deployment container.
```
google-adk[a2a]
python-dotenv
requests
pydantic
cloudpickle
google-cloud-aiplatform
```

# Agent rules

- Always present the plan to the user before asking for confirmation to proceed with implementation.
- Use the variable names `SERVICENOW_INSTANCE`, `SERVICENOW_USERNAME`, and `SERVICENOW_PASSWORD` for the ServiceNow url, username, and password. These will already be set for you. If the value of the env var `SERVICENOW_PASSWORD` has the prefix `secret-`, use its value as the secret name and get its real value from Secret Manager. Implement a fallback in the secret-resolution helper: first attempt lookup using the full env var value. If a `NotFound` error occurs, strip the `secret-` prefix (i.e., `value[7:]`) and retry the lookup.
- Do not display sensitive information like passwords on the screen.

# Self-Correction Protocols
- **Thorough Requirement Review:** Before creating a plan, I will thoroughly review all provided documents (e.g., design docs). I will create a checklist of all explicit requirements and deliverables to ensure the plan addresses every item.
- **Proactive Convention Analysis:** When using a new or unfamiliar framework (like Google ADK), I will first investigate its core conventions. This will be done *before* implementation to avoid reactive, trial-and-error debugging. This includes:
    - **Verifying Constructor Arguments:** For any framework-specific class (e.g., `FunctionTool`), I will explicitly verify the names of all required arguments (`func` vs. `fn`) from documentation or examples before using them.
    - **Checking Naming Conventions:** I will adhere to established naming conventions (e.g., `root_agent`).
- **Strict Order of Operations:** I will strictly adhere to the prescribed order of operations, especially ensuring that the plan is *always* presented to the user before asking for confirmation to proceed with implementation.
- **F-string Syntax Verification:** I will meticulously review f-string syntax, particularly when using nested f-strings or conditional expressions within them, to ensure correct formatting and prevent syntax errors.
- **Plan Presentation Order:** Always present the detailed plan to the user *before* asking for confirmation to proceed with implementation. This ensures transparency and allows the user to review the proposed steps.
- **Adherence to Plan Presentation:** I will ensure that I *always* present the formulated plan to the user *before* asking for confirmation to proceed with implementation, as explicitly stated in the "Agent rules" and "Self-Correction Protocols." I acknowledge that I failed to do this in the previous interaction and will prioritize this step moving forward.
