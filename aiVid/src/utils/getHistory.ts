import axios from "axios"

interface Response {
    data: {
        url: string
        _id: string
        prompt: string
        timestamp: string
        __v: number
    }[]
}

export const getHistory = async (): Promise<Response | undefined> => {
    let config = {
        method: 'get',
        maxBodyLength: Infinity,
        url: 'http://localhost:8000/api/urls/',
        headers: { 
          'Content-Type': 'application/json'
        }
    }

    try {
        const response = await axios.request(config)
        // console.log('this data', response.data)
        return response.data
    } catch (error) {
        return undefined
    }   
}