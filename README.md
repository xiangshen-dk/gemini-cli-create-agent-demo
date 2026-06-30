# Gemini CLI Pollux Demo

This demo is designed to be run exclusively in Google Cloud Shell.

## Common Setup Steps

1. Configure your gcloud by running `gcloud auth login`
2. Clone this demo repo: `git clone -b agy https://github.com/xiangshen-dk/gemini-cli-create-agent-demo`
3. Create a `.env` in the `gemini-cli-create-agent-demo` folder that has these environment variables:

    ```
    GEMINI_MODEL=gemini-3.5-flash
    GOOGLE_GENAI_USE_VERTEXAI=1
    GOOGLE_CLOUD_PROJECT=adk-agent-gemini-cli-1482
    GOOGLE_CLOUD_LOCATION=global
    SERVICENOW_INSTANCE=https://ven04789.service-now.com
    SERVICENOW_USERNAME=inventory_user
    SERVICENOW_PASSWORD=secret-service_now_password
    ```
4. You can inspect the design doc `design-doc-ServiceNow-inventory-agent.md` in your editor.
5. Run the `init.sh` file in `gemini-cli-create-agent-demo`: `./init.sh`
    * The init.sh will ask you if you want to preload the prompt. If you answer y, it will delete the prompt history for ALL your Gemini CLI instances.

## Setup in Google Cloud Shell

Google Cloud Shell comes with `gcloud` and `gemini` pre-installed and authenticated. After completing the [Common Setup Steps](#common-setup-steps), follow these steps:

1. Run gemini from the `gemini-cli-create-agent-demo` folder.

## Prompts

1. I would like to build an inventory agent that follows this design doc: `design-doc-ServiceNow-inventory-agent.md` Can you create a plan?
2. Yes
3. Deploy

## Reset demo

1. In `gemini-cli-create-agent-demo`, run the reset script: `./reset.sh`
