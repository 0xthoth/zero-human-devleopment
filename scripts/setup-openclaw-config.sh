#!/bin/bash

# OpenClaw Configuration Setup Script
# This script helps you set up openclaw.json from the template

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATE_FILE="$PROJECT_ROOT/.openclaw/openclaw.json.template"
CONFIG_FILE="$PROJECT_ROOT/.openclaw/openclaw.json"
BACKUP_FILE="$PROJECT_ROOT/.openclaw/openclaw.json.backup.$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       OpenClaw Configuration Setup                         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if template exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}Error: Template file not found at $TEMPLATE_FILE${NC}"
    exit 1
fi

# Check if config already exists
if [ -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}⚠️  Warning: openclaw.json already exists!${NC}"
    echo ""
    read -p "Do you want to backup and overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Setup cancelled.${NC}"
        exit 1
    fi

    # Create backup
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo -e "${GREEN}✓ Backup created at: $BACKUP_FILE${NC}"
    echo ""
fi

echo -e "${BLUE}📋 This script will guide you through setting up your OpenClaw configuration.${NC}"
echo -e "${BLUE}You'll need the following Discord information:${NC}"
echo ""
echo "  1. Discord Bot Token (from Discord Developer Portal)"
echo "  2. Discord Guild (Server) ID"
echo "  3. Your Discord User ID"
echo "  4. Owner Channel ID (private planning channel)"
echo "  5. Team Channel ID (public coordination channel)"
echo ""
echo -e "${YELLOW}💡 Tip: Enable Developer Mode in Discord (User Settings → Advanced → Developer Mode)${NC}"
echo -e "${YELLOW}   Then right-click on servers/channels/users to copy their IDs.${NC}"
echo ""

# Function to validate Discord ID (should be numeric and 17-19 digits)
validate_discord_id() {
    local id="$1"
    local name="$2"

    if [[ ! "$id" =~ ^[0-9]{17,19}$ ]]; then
        echo -e "${RED}Error: Invalid $name. Discord IDs should be 17-19 digit numbers.${NC}"
        return 1
    fi
    return 0
}

# Function to validate Discord token (basic check)
validate_discord_token() {
    local token="$1"

    # Discord bot tokens have a specific format: base64.base64.random_string
    if [[ ! "$token" =~ ^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$ ]]; then
        echo -e "${YELLOW}⚠️  Warning: Token format looks unusual. Discord bot tokens usually have format: XXX.YYY.ZZZ${NC}"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    return 0
}

# Prompt for Discord Bot Token
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}1. Discord Bot Token${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Get your bot token from: https://discord.com/developers/applications"
echo "Navigate to: Your Application → Bot → Token → Reset Token"
echo ""

while true; do
    read -p "Enter Discord Bot Token: " DISCORD_BOT_TOKEN
    if [ -z "$DISCORD_BOT_TOKEN" ]; then
        echo -e "${RED}Error: Token cannot be empty.${NC}"
        continue
    fi
    if validate_discord_token "$DISCORD_BOT_TOKEN"; then
        break
    fi
done

echo ""

# Prompt for Guild ID
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}2. Discord Guild (Server) ID${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Right-click on your Discord server name and select 'Copy Server ID'"
echo ""

while true; do
    read -p "Enter Guild ID: " GUILD_ID
    if validate_discord_id "$GUILD_ID" "Guild ID"; then
        break
    fi
done

echo ""

# Prompt for User ID
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}3. Your Discord User ID${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Right-click on your username/avatar and select 'Copy User ID'"
echo ""

while true; do
    read -p "Enter Your User ID: " USER_ID
    if validate_discord_id "$USER_ID" "User ID"; then
        break
    fi
done

echo ""

# Prompt for Owner Channel ID
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}4. Owner Channel ID (Private Planning Channel)${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "This is your private channel for planning (e.g., #owner)"
echo "Right-click on the channel and select 'Copy Channel ID'"
echo ""

while true; do
    read -p "Enter Owner Channel ID: " OWNER_CHANNEL_ID
    if validate_discord_id "$OWNER_CHANNEL_ID" "Owner Channel ID"; then
        break
    fi
done

echo ""

# Prompt for Team Channel ID
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}5. Team Channel ID (Public Coordination Channel)${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "This is your public channel for team coordination (e.g., #team)"
echo "Right-click on the channel and select 'Copy Channel ID'"
echo ""

while true; do
    read -p "Enter Team Channel ID: " TEAM_CHANNEL_ID
    if validate_discord_id "$TEAM_CHANNEL_ID" "Team Channel ID"; then
        break
    fi
done

echo ""

# Generate gateway auth token
echo -e "${BLUE}🔐 Generating secure gateway authentication token...${NC}"
GATEWAY_AUTH_TOKEN=$(openssl rand -hex 24 2>/dev/null || head -c 24 /dev/urandom | xxd -p -c 24)

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📝 Configuration Summary${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Discord Bot Token: ${DISCORD_BOT_TOKEN:0:20}...${DISCORD_BOT_TOKEN: -10}"
echo "Guild ID: $GUILD_ID"
echo "User ID: $USER_ID"
echo "Owner Channel ID: $OWNER_CHANNEL_ID"
echo "Team Channel ID: $TEAM_CHANNEL_ID"
echo "Gateway Auth Token: ${GATEWAY_AUTH_TOKEN:0:20}...${GATEWAY_AUTH_TOKEN: -10}"
echo ""

read -p "Continue with these settings? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${RED}Setup cancelled.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}📝 Creating configuration file...${NC}"

# Copy template and replace placeholders
cp "$TEMPLATE_FILE" "$CONFIG_FILE"

# Use sed to replace placeholders (macOS and Linux compatible)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|<YOUR_DISCORD_BOT_TOKEN>|$DISCORD_BOT_TOKEN|g" "$CONFIG_FILE"
    sed -i '' "s|<YOUR_GUILD_ID>|$GUILD_ID|g" "$CONFIG_FILE"
    sed -i '' "s|<YOUR_DISCORD_USER_ID>|$USER_ID|g" "$CONFIG_FILE"
    sed -i '' "s|<YOUR_OWNER_CHANNEL_ID>|$OWNER_CHANNEL_ID|g" "$CONFIG_FILE"
    sed -i '' "s|<YOUR_TEAM_CHANNEL_ID>|$TEAM_CHANNEL_ID|g" "$CONFIG_FILE"
    sed -i '' "s|<GENERATE_ON_FIRST_START>|$GATEWAY_AUTH_TOKEN|g" "$CONFIG_FILE"
else
    # Linux
    sed -i "s|<YOUR_DISCORD_BOT_TOKEN>|$DISCORD_BOT_TOKEN|g" "$CONFIG_FILE"
    sed -i "s|<YOUR_GUILD_ID>|$GUILD_ID|g" "$CONFIG_FILE"
    sed -i "s|<YOUR_DISCORD_USER_ID>|$USER_ID|g" "$CONFIG_FILE"
    sed -i "s|<YOUR_OWNER_CHANNEL_ID>|$OWNER_CHANNEL_ID|g" "$CONFIG_FILE"
    sed -i "s|<YOUR_TEAM_CHANNEL_ID>|$TEAM_CHANNEL_ID|g" "$CONFIG_FILE"
    sed -i "s|<GENERATE_ON_FIRST_START>|$GATEWAY_AUTH_TOKEN|g" "$CONFIG_FILE"
fi

# Update lastTouchedAt timestamp
CURRENT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|\"lastTouchedAt\": \".*\"|\"lastTouchedAt\": \"$CURRENT_TIMESTAMP\"|g" "$CONFIG_FILE"
else
    sed -i "s|\"lastTouchedAt\": \".*\"|\"lastTouchedAt\": \"$CURRENT_TIMESTAMP\"|g" "$CONFIG_FILE"
fi

# Set proper permissions
chmod 600 "$CONFIG_FILE"

echo -e "${GREEN}✓ Configuration file created successfully!${NC}"
echo ""

# Validate JSON
echo -e "${BLUE}🔍 Validating JSON syntax...${NC}"
if command -v jq &> /dev/null; then
    if jq empty "$CONFIG_FILE" 2>/dev/null; then
        echo -e "${GREEN}✓ JSON syntax is valid${NC}"
    else
        echo -e "${RED}✗ JSON syntax error detected!${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  jq not found, skipping JSON validation${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Configuration file created at: $CONFIG_FILE"
echo "Permissions set to: 600 (read/write for owner only)"
echo ""
echo -e "${BLUE}🔐 IMPORTANT - Gateway Authentication Token:${NC}"
echo ""
echo -e "${YELLOW}Your gateway token: ${GATEWAY_AUTH_TOKEN}${NC}"
echo ""
echo "You MUST enter this token in the browser to access the dashboard:"
echo "  1. Open: http://\${PROJECT_NAME}.openclaw.localhost"
echo "  2. Click Settings (⚙️ icon) in the Control UI"
echo "  3. Paste the token above in 'Gateway Token' field"
echo "  4. Save and refresh"
echo ""
echo "To retrieve this token later: ${YELLOW}make openclaw-gateway-token${NC}"
echo ""
echo -e "${BLUE}📚 Next Steps:${NC}"
echo ""
echo "1. Restart OpenClaw gateway:"
echo -e "   ${YELLOW}make openclaw-restart${NC}"
echo ""
echo "2. Access the dashboard and enter the gateway token (see above)"
echo ""
echo "3. Verify the configuration:"
echo -e "   ${YELLOW}docker exec 0xthoth-gateway openclaw doctor${NC}"
echo ""
echo "4. Check Discord connection:"
echo -e "   ${YELLOW}docker exec 0xthoth-gateway openclaw channels status${NC}"
echo ""
echo "5. List agents:"
echo -e "   ${YELLOW}make agents-list${NC}"
echo ""
echo -e "${GREEN}🎉 Your OpenClaw multi-agent system is ready to use!${NC}"
echo ""

exit 0
