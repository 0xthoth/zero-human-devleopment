# OpenClaw Browser Pairing - Simple Guide

## 🎯 One-Command Setup (EASIEST!)

```bash
make openclaw-pair-quick
```

That's it! This command will:
1. ✅ Show you the gateway token (auto-copied)
2. ✅ Tell you what URL to open
3. ✅ Wait and auto-approve when you save the token
4. ✅ Confirm when pairing is successful

---

## 📋 Manual Steps (If you prefer step-by-step)

### Step 1: Get Your Token
```bash
make openclaw-gateway-token
```
**Copy the token** that appears (it's a long string like `9d97734bd208738f...`)

### Step 2: Open OpenClaw
Open this URL in your browser:
```
http://0xthoth.openclaw.localhost
```

### Step 3: Enter Token
1. Click the **⚙️ Settings icon** (usually in top-right corner)
2. Find the field labeled **"Gateway Token"**
3. **Paste** your token
4. Click **"Save"** or press **Enter**

### Step 4: Approve Pairing
In your terminal, run:
```bash
make openclaw-devices-auto-approve
```

If you see "No pending requests", wait 5 seconds and try again.

### Step 5: Refresh Browser
Refresh the OpenClaw page in your browser. You should now be connected!

---

## 🔧 Troubleshooting

### Error: "device token mismatch"
**Solution:** Your browser needs re-pairing
```bash
make openclaw-pair-quick
```
Follow the prompts.

### Error: "pairing required"
**Solution:** Approve the pending request
```bash
make openclaw-devices-auto-approve
```

### Auto-approve doesn't find the request
**Solution:** Use the watch command
```bash
make openclaw-pair-watch
```
Then go enter your token in the browser. This will auto-approve it.

### Still having issues?
1. List all devices: `make openclaw-devices-list`
2. Get a fresh token: `make openclaw-gateway-token`
3. Try the quick setup: `make openclaw-pair-quick`

---

## 🎓 Understanding the Process

**What happens:**
1. You enter a gateway token in the browser
2. Your browser sends a "pairing request" to OpenClaw
3. The request must be approved in the terminal
4. Once approved, your browser can access OpenClaw

**Why it fails:**
- Timing: The request expires quickly if not approved
- Old tokens: Tokens from different sessions don't work
- Missing approval: Auto-approve might not catch the request

**The fix:**
Use `openclaw-pair-quick` - it handles everything automatically!
