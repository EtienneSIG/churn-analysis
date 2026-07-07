# Rayfin — Optional Bonus Module

## Contoso Banque — Churn Analysis Workshop

> ⚠️ **This section is entirely optional.** It requires Node.js 18+, npm, and depends on Rayfin feature availability in your tenant/region. If you are short on time or the feature is not available, skip this module — it does not affect the core workshop.

---

## What Is Rayfin?

**Rayfin** is a Microsoft open-source project that provides a semantic search and natural language querying backend on top of Microsoft Fabric data. It is designed to enable more advanced AI-powered data exploration than the built-in Fabric Data Agent.

Key capabilities:
- Connects to Fabric Lakehouse and Warehouse data.
- Provides a REST API that front-end applications can call.
- Supports semantic search over tabular data.
- Can be used to build custom conversational analytics experiences.

> **Where to find it:** [https://github.com/microsoft/rayfin](https://github.com/microsoft/rayfin) (check for the latest README and installation instructions, as the project may have evolved since this workshop was written).

---

## When Would You Use Rayfin vs. Fabric Data Agent?

| Scenario | Fabric Data Agent | Rayfin |
|---|---|---|
| Quick Q&A for business users | ✅ Best choice | Overkill |
| No-code setup | ✅ Built-in | ❌ Requires Node.js setup |
| Custom front-end application | ❌ Hard to embed | ✅ REST API available |
| Advanced semantic search | ❌ Not supported | ✅ Core capability |
| Fully managed service | ✅ Managed by Fabric | ❌ Self-hosted |
| Beginner-friendly | ✅ Yes | ❌ Requires dev setup |

**Use Rayfin if:** You want to build a custom application that queries Fabric data programmatically, or if you need semantic search capabilities beyond what the built-in Data Agent provides.

---

## Prerequisites for Rayfin

Before attempting this module, ensure you have:

- [ ] Node.js **18 or later** installed: [https://nodejs.org](https://nodejs.org)
- [ ] npm (included with Node.js)
- [ ] git installed: [https://git-scm.com](https://git-scm.com)
- [ ] A terminal (PowerShell, Command Prompt, or VS Code terminal)
- [ ] Your Fabric Lakehouse SQL analytics endpoint connection string
- [ ] Core workshop modules completed (Steps 1–8)

Check your Node.js version:
```bash
node --version
# Should output v18.x.x or higher
```

---

## Installation (High-Level Steps)

> **Important:** Always consult the [official Rayfin GitHub README](https://github.com/microsoft/rayfin) for the most current installation instructions, as the project may have been updated since this workshop was written. The steps below are illustrative.

### 1. Clone the Rayfin Repository

```bash
git clone https://github.com/microsoft/rayfin.git
cd rayfin
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Connection to Fabric

Create a `.env` file in the Rayfin root directory with your Fabric connection details:

```env
# Rayfin configuration — Contoso Banque workshop
FABRIC_SQL_ENDPOINT=<your-sql-analytics-endpoint-connection-string>
FABRIC_DATABASE=ChurnAnalysisLH
FABRIC_AUTH_METHOD=AzureAD

# Optional: specify which tables to expose
RAYFIN_TABLES=customer_360,churn_by_segment
```

> **Finding your SQL endpoint:** In your Lakehouse → SQL analytics endpoint → click the connection string / copy icon.

### 4. Authenticate

Rayfin uses Azure AD for authentication. You may need to run:

```bash
az login
```

or configure a service principal. See the Rayfin documentation for the authentication method that applies to your environment.

### 5. Start the Rayfin Service

```bash
npm start
```

If successful, you should see output like:
```
Rayfin server running on http://localhost:3000
Connected to Fabric SQL endpoint: <your-endpoint>
```

---

## Testing Rayfin

Once running, you can test Rayfin by sending HTTP requests:

```bash
# Using curl
curl -X POST http://localhost:3000/query \
  -H "Content-Type: application/json" \
  -d '{"question": "What is the overall churn rate?"}'
```

Expected response (illustrative):
```json
{
  "question": "What is the overall churn rate?",
  "answer": "The overall churn rate is 20.3%",
  "sql": "SELECT ROUND(100.0 * SUM(churned_90d) / COUNT(*), 2) AS churn_rate FROM customer_360",
  "data": [{"churn_rate": 20.3}]
}
```

---

## Rayfin vs. Fabric Data Agent — Side by Side Demo

If you have both running, try asking the same question to both:

**Question:** *"Which customer segment has the highest churn rate?"*

| | Fabric Data Agent | Rayfin |
|---|---|---|
| Interface | Browser chat UI | REST API / CLI |
| Response format | Natural language + SQL | JSON with SQL |
| Setup time | 5 minutes | 30–45 minutes |
| Customization | Instructions text | Code-level |

---

## Integration Ideas (Advanced)

Once Rayfin is running, you could:

1. **Build a custom chat interface** using a React or Streamlit app that calls the Rayfin REST API.
2. **Integrate into Teams** as a bot that answers banking analytics questions.
3. **Embed in a portal** to give non-technical users a search bar for Fabric data.
4. **Combine with Power BI Embedded** for a fully custom analytics experience.

These are advanced scenarios beyond the scope of this workshop.

---

## Cleanup

When finished with the bonus module:

```bash
# Stop the Rayfin service
Ctrl+C in the terminal

# Optional: remove the cloned repo
cd ..
rm -rf rayfin
```

---

## Troubleshooting Rayfin

| Problem | Solution |
|---|---|
| `node: command not found` | Install Node.js from [https://nodejs.org](https://nodejs.org) |
| Connection to Fabric fails | Check your SQL endpoint string; ensure you are authenticated with `az login` |
| Port 3000 already in use | Change the port in the `.env` file (e.g., `PORT=3001`) |
| Azure AD token errors | Ensure you have the correct permissions on the Lakehouse |
| Tables not found | Verify the table names match exactly (case-sensitive) |

---

## Resources

- [Rayfin GitHub repository](https://github.com/microsoft/rayfin)
- [Microsoft Fabric SQL analytics endpoint](https://learn.microsoft.com/fabric/data-engineering/lakehouse-sql-analytics-endpoint)
- [Node.js download](https://nodejs.org)
- [Azure CLI — az login](https://learn.microsoft.com/cli/azure/authenticate-azure-cli)
