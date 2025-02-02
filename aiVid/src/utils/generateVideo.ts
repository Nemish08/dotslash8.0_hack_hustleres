import axios from "axios"

export const generateVideo = async (uuid: string, script: string, orientation: string) => {
    let data = JSON.stringify({
        "script": script,
        "uuid": uuid,
        "orientation": orientation
    })
      
    let config = {
        method: 'post',
        maxBodyLength: Infinity,
        url: 'http://localhost:5000/api/generate_2',
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