import axios from "axios"

export const postHistory = async (url: string, prompt: string) => {
    let data = JSON.stringify({
        "url": url,
        "prompt": prompt
    })
      
    let config = {
        method: 'post',
        maxBodyLength: Infinity,
        url: 'http://localhost:8000/api/urls/setHistory',
        headers: { 
          'Content-Type': 'application/json'
        },
        data : data
    }

    try {
        const response = await axios.request(config)
        return response.data
    } catch (error) {
        return undefined
    }   
}