import axios from "axios"

interface Response {
    script: string
}

export const generateScript = async (prompt: string, uuid: string, webSearch: boolean): Promise<Response | undefined> => {
    let data = JSON.stringify({
        "prompt": prompt,
        "uuid": uuid,
        "web_search": webSearch
    })
      
    let config = {
        method: 'post',
        maxBodyLength: Infinity,
        url: 'http://localhost:5000/api/generate_script',
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