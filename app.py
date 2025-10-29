import streamlit as st
import pandas as pd
import plotly.express as px
from supabase import create_client, Client
import os
from dotenv import load_dotenv
import requests
# ==========================
# Load .env
# ==========================
SUPABASE_URL = st.secrets["SUPABASE_URL"]
SUPABASE_KEY = st.secrets["SUPABASE_KEY"]
OPENROUTER_API_KEY = st.secrets["OPENROUTER_API_KEY"]

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# ==========================
# LLM Generator
# ==========================
def generate_with_llm(prompt: str):
    try:
        headers = {
            "Authorization": f"Bearer {OPENROUTER_API_KEY}",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://share.streamlit.io",  # penting agar request diterima
            "X-Title": "Talent Match Dashboard"  # judul app kamu
        }

        data = {
            "model": "openai/gpt-oss-20b:free",  # ganti model yang pasti tersedia gratis
            "messages": [{"role": "user", "content": prompt}],
        }

        response = requests.post(
            "https://openrouter.ai/api/v1/chat/completions",
            headers=headers,
            json=data
        )

        if response.status_code == 200:
            return response.json()['choices'][0]['message']['content']
        else:
            return f"Gagal generate dari LLM. Status code: {response.status_code} | Detail: {response.text}"

    except Exception as e:
        return f"Error: {e}"

# ==========================
# Streamlit UI
# ==========================
st.title("Talent Match & Job Insights Dashboard")

# Ambil daftar role dari Supabase
roles_resp = supabase.table("final_match_summary").select("role").execute()
role_list = sorted(list({row['role'] for row in roles_resp.data})) if roles_resp.data else []

if not role_list:
    st.warning("Tidak ada role tersedia di database.")
    st.stop()

# ==========================
# Input Role Form
# ==========================
with st.form("role_form"):
    st.subheader("Input Role")
    role_name = st.selectbox("Role Name", role_list)
    generate_desc = st.checkbox("Generate Job Description & Competencies using LLM")
    submitted = st.form_submit_button("Process")

# ==========================
# Process Output
# ==========================
if submitted:
    # --------------------------
    # Fetch data dari Supabase
    # --------------------------
    with st.spinner("Fetching data from Supabase..."):
        response_all = supabase.table("final_match_summary").select("*").eq("role", role_name).execute()
        df_all = pd.DataFrame(response_all.data)

    # --------------------------
    # Generate LLM Job Description / Requirements
    # --------------------------
    if generate_desc:
        prompt = f"""
        Berdasarkan role '{role_name}', 
        buatkan Job Requirements, Job Description, dan Key Competencies 
        yang relevan dengan role tersebut.
        """
        llm_output = generate_with_llm(prompt)
        formatted_text = llm_output.replace("\n", "<br>")
        st.markdown(f"""
        <div style="font-size:16px; line-height:1.4;">
        {formatted_text}
        </div>
        """, unsafe_allow_html=True)

    # --------------------------
    # Ranked Talent List
    # --------------------------
    if df_all.empty:
        st.warning(f"Tidak ditemukan data untuk role: {role_name}")
    else:
        df_sorted_all = df_all.sort_values(by="final_match_rate", ascending=False).reset_index(drop=True)
        df_sorted_all.index += 1
        st.subheader("Ranked Talent List (All Employees for Role)")
        st.dataframe(df_sorted_all[[
            "employee_id", "tgv_name", "tv_name", "baseline_score", "user_score", "final_match_rate"
        ]])

        # --------------------------
        # Visualization
        # --------------------------
        st.subheader("Distribusi Final Match Rate")
        fig_dist = px.histogram(
            df_sorted_all,
            x="final_match_rate",
            nbins=10,
            title=f"Distribusi Final Match Rate - Role: {role_name}",
            labels={"final_match_rate": "Final Match Rate"}
        )
        st.plotly_chart(fig_dist, use_container_width=True)






