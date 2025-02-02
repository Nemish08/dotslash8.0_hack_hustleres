import { ArrowBigLeft, CheckCircle2, ChevronLeft, Globe, House, RectangleHorizontal, RectangleVertical, SendHorizonal, Sparkles, Square, Wand } from "lucide-react";
import HeaderHome from "../home/header/HeaderHome"
import { useEffect, useState } from "react"
import Cookies from "universal-cookie"
import { generateScript } from "../../utils/generateScript"
import { useNavigate } from "react-router-dom";
import { postHistory } from "../../utils/postHistory";

enum Stage {
    PROMPT,
    ORIENTATION,
    VIDEO_GENERATION,
    DONE
}

interface Option {
    id: string
    icon?: string
    label: string
}

export default function AiVideoGenerator() {
    const cookies = new Cookies(null, { path: '/' })
    const [prompt, setPrompt] = useState("")
    const [orientation, setOrientation] = useState("landscape")
    const [voice, setVoice] = useState("us-male-1")
    const [stage, setStage] = useState(Stage.PROMPT)
    const [script, setScript] = useState("")
    const [loader, setLoader] = useState(false)
    const navigate = useNavigate()

    const [progress, setProgress] = useState<number>(0)
    const [message, setMessage] = useState<string>("Starting process...")
    const [done, setDone] = useState<boolean>(false)
    const [videoUrl, setVideoUrl] = useState<string>("")

    const [webSearch, setWebSearch] = useState<boolean>(false)

    const options: Option[] = [
        { id: 'us-male-1', icon: '♂', label: 'Male 1' },
        { id: 'us-male-3', icon: '♂', label: 'Male 2' },
        { id: 'us-female-1', icon: '♀', label: 'Female 1' },
        { id: 'us-female-3', icon: '♀', label: 'Female 2' }
    ]

    const [subtitle, setSubtitle] = useState("wbn")
    const subtitleOptions: Option[] = [
        { id: 'wbn', label: 'White text, black background, normal style' },
        { id: 'wtn', label: 'White text, transparent background, normal style'},
        { id: 'ybn', label: 'Yellow text, black background, normal style' },
        { id: 'ytn', label: 'Yellow text, transparent background, normal style'},
        { id: 'wbi', label: 'White text, black background, italic style' },
        { id: 'wti', label: 'White text, transparent background, italic style'},
        { id: 'ybi', label: 'Yellow text, black background, italic style' },
        { id: 'yti', label: 'Yellow text, transparent background, italic style'}
    ]

    useEffect(() => {
        if (!cookies.get('uid') || !cookies.get('email')) 
            navigate('/')
    }, [])

    useEffect(() => {
        window.scrollTo(0, 0)
    }, [])

    const handleGenerateScript = async () => {
        if (prompt === "") return
        setLoader(true)
        const res = await generateScript(prompt, cookies.get('uid'), webSearch)
        setScript(res?.script!)
        console.log(res?.script)
        // setPrompt('')
        setStage(Stage.ORIENTATION)
        setLoader(false)
    }

    // const startGeneration = async () => {
    //     setLoader(true)
    //     setStage(Stage.VIDEO_GENERATION)
    //     const response = await fetch("http://localhost:5000/api/generate_2", {
    //       method: "POST",
    //       headers: {
    //         "Content-Type": "application/json",
    //       },
    //       body: JSON.stringify({
    //         script: script,
    //         uuid: cookies.get('uid'),
    //         orientation: orientation,
    //         style: subtitle,
    //         voice_id: voice
    //       }),
    //     })
    
    //     // Ensure the response is streamed
    //     if (!response.body) {
    //       console.error("Streaming not supported by the browser.")
    //       return
    //     }
    
    //     const reader = response.body.getReader()
    //     const decoder = new TextDecoder("utf-8")
    //     let completeMessage = ""
    
    //     while (true) {
    //       const { done, value } = await reader.read()
        
    //       completeMessage += decoder.decode(value, { stream: true })
    //       const messages = completeMessage.split("\n").filter((msg) => msg.trim() !== "")
    
    //       messages.forEach((msg) => {
    //         try {
    //           const data = JSON.parse(msg)
    //           setProgress(data.progress || 0)
    //           setMessage(data.msg || "Processing...")
    //           setDone(data.done || false)

    //           setVideoUrl(data.url || "")

    //           console.log(data)
    //         } catch (e) {
    //           console.error("Error parsing streamed data", e)
    //         }
    //       })

    //       if (done) break

    //     }
    //     setStage(Stage.DONE)
    //     setLoader(false)
    // }

    const startGeneration = async () => {
        setLoader(true)
        setStage(Stage.VIDEO_GENERATION)
        try {
            const response = await fetch("http://localhost:5000/api/generate_img_content", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    prompt: prompt,
                    script: script,
                    uuid: cookies.get('uid'),
                    orientation: orientation,
                    style: subtitle,
                    voice_id: voice
                }),
            })
    
            if (!response.body) {
                console.error("Streaming not supported by the browser.")
                return
            }
    
            const reader = response.body.getReader()
            const decoder = new TextDecoder("utf-8")
            let completeMessage = ""
            let lastData = null
    
            while (true) {
                const { done, value } = await reader.read()
                
                if (done) {
                    // Process any remaining data in completeMessage
                    if (completeMessage) {
                        try {
                            const data = JSON.parse(completeMessage.trim())
                            if (data.url) {
                                setVideoUrl(data.url)
                            }
                            lastData = data
                        } catch (e) {
                            console.error("Error parsing final message:", e)
                        }
                    }
                    break
                }
    
                completeMessage += decoder.decode(value, { stream: true })
                
                // Split by newlines and process each complete message
                const lines = completeMessage.split("\n")
                
                // Keep the last potentially incomplete line in completeMessage
                completeMessage = lines.pop() || ""
    
                // Process all complete lines
                for (const line of lines) {
                    if (line.trim()) {
                        try {
                            const data = JSON.parse(line)
                            setProgress(data.progress || 0)
                            setMessage(data.msg || "Processing...")
                            setDone(data.done || false)
                            
                            // Store the URL if it exists
                            if (data.url) {
                                setVideoUrl(data.url)
                                postHistory(data.url, prompt)
                            }
                            lastData = data
                        } catch (e) {
                            console.error("Error parsing streamed data:", e, "Line:", line)
                        }
                    }
                }
            }
    
            // Final state updates
            if (lastData?.done) {
                setStage(Stage.DONE)
                if (lastData.url) {
                    setVideoUrl(lastData.url)
                }
            }
        } catch (error) {
            console.error("Error in startGeneration:", error)
            setMessage("An error occurred during generation")
            setDone(true)
        } finally {
            setLoader(false)
        }
    }

    const handleSelectVoice = (voice: string) => {
        setVoice(voice)
        const audio = new Audio(`/assets/${voice}.mp3`)
        audio.play()
    }

    return (
        <div className="w-[60%] relative h-full flex flex-col items-center justify-start">
            <HeaderHome />

            <div className="fixed w-full h-full inset-0 overflow-hidden z-10">
                <div className='w-full h-full relative'>
                    <div className="absolute -top-36 -left-40 w-96 h-60 bg-emerald-800/80 rounded-full  mix-blend-multiply filter blur-3xl"></div>
                    <div className="absolute top-0 -right-40 w-96 h-96 bg-green-900/30 rounded-full mix-blend-multiply filter blur-3xl"></div>
                    {/* <div className="absolute -bottom-40 left-20 w-96 h-96 bg-teal-900/30 rounded-full mix-blend-multiply filter blur-3xl">THIHISHSIH</div> */}
                </div>
            </div>
            
            {stage === Stage.PROMPT && 
                <div className="w-[70%] z-20 h-full gap-5 flex flex-col items-center justify-start mt-5">
                    <div className="w-full flex items-center justify-start gap-2">
                        <button onClick={() => navigate(-1)} title="Go back" className="self-start hover:cursor-pointer hover:opacity-60 mt-1"><ChevronLeft className="w-5 h-5" strokeWidth={3} /></button>
                        <p className="text-xl font-semibold">Generate Videos by merging AI generated images</p>
                    </div>
                    <div className="w-full h-full gap-5 flex flex-col items-center justify-start">
                        <div className="w-full p-4 gap-5 flex flex-col items-start justify-start rounded-lg bg-[#1b1b1b] border border-gray-800">
                            <textarea
                                value={prompt}
                                onChange={(e) => setPrompt(e.target.value)}
                                rows={5} 
                                className="w-full  resize-none h-full bg-transparent p-2 outline-none border-none"
                                placeholder="Enter topic or description to generate video on"
                            ></textarea>

                            <div className="flex w-full items-end justify-end gap-3">
                                <button onClick={() => setWebSearch(!webSearch)} title="Web search"><Globe className={`w-5 h-5 hover:cursor-pointer hover:opacity-60 ${webSearch ? "text-green-600" : ""}`} /></button>
                                <button onKeyDown={e => {
                                    if (e.key === 'Enter') 
                                        handleGenerateScript()
                                }} onClick={handleGenerateScript} title="Generate script">
                                    {!loader ? 
                                        <SendHorizonal className="w-5 h-5 hover:cursor-pointer hover:opacity-60" />:
                                        <div
                                            className="inline-block h-5 w-5 animate-spin rounded-full border-3 border-green-600 border-solid border-r-transparent align-[-0.125em] motion-reduce:animate-[spin_1.5s_linear_infinite]"
                                            role="status">
                                      </div>
                                      }
                                </button>
                            </div>
                        </div>
                    </div>

                    <div className="w-full h-full flex flex-col p-3 rounded-lg border border-white/20 items-start justify-start">
                        <p>Suggestions</p>

                        <div className="text-xs w-full mt-1 gap-2 flex items-start justify-start">
                            <p className="p-3 rounded-xl border border-green-800">video about dogs vs cats</p>
                            <p className="p-3 rounded-xl border border-green-800">ai ruling on earth</p>
                            <p className="p-3 rounded-xl border border-green-800">nature and environment</p>
                        </div>
                    </div>

                    <div className="w-full h-full flex flex-col p-3 rounded-lg border border-white/20 items-start justify-start">
                        <p>Examples</p>

                        <div className="text-xs w-full gap-2 mt-3 flex flex-col items-start justify-start">
                            <video
                                controls
                                className="rounded-lg" 
                                src="https://res.cloudinary.com/djc4fwyrc/video/upload/v1738238186/mOXWUrIShsghrgx2xIJ5I6nIFcA3/20250130_172623_mOXWUrIShsghrgx2xIJ5I6nIFcA3_subtitle_final_1738238166.3767724.mp4"></video>
                            <p>Prompt: 3 students coding hard on the day of hackathon</p>
                            <p>Orientation: landscape</p>
                        </div>

                        <div className="text-xs w-full gap-2 mt-12 flex flex-col items-start justify-start">
                            <video
                                controls
                                className="rounded-lg w-[50%] self-center" 
                                src="https://res.cloudinary.com/djc4fwyrc/video/upload/v1738073490/187nksnuuhw7/20250128_194128_187nksnuuhw7_subtitle_final_1738073473.5804157.mp4"></video>
                            <p>Prompt: a boy who thinks he is harry potter but wakes up dreaming</p>
                            <p>Orientation: portrait</p>
                        </div>
                    </div>
                </div>

            }  

            {stage === Stage.ORIENTATION && 
            <div className="w-[70%] z-20 h-full flex flex-col items-start justify-start gap-3 mt-5">
                <button onClick={() => {
                    setStage(Stage.PROMPT)
                    setOrientation("landscape")
                }} title="Go back" className="hover:cursor-pointer hover:opacity-60"><ChevronLeft className="w-5 h-5" strokeWidth={3} /></button>
                <div className="w-full p-4 gap-5 flex flex-col items-start justify-start rounded-lg border border-gray-800">
                    <p className="font-medium">Generated script</p>
                    <p className="text-sm text-gray-300">{script}</p>
                </div>
                <div className="w-full p-4 gap-5 flex flex-col items-start justify-start rounded-lg border border-gray-800">
                    <p className="font-medium">Select screen orientation</p>

                    <div className="w-full p-4 gap-3 flex items-center justify-center">
                        <div className={`hover:cursor-pointer hover:border-green-500 transition-all duration-300 hover:bg-[#141414] w-full p-4 flex flex-col items-center justify-center rounded-lg bg-[#1b1b1b] border py-8 border-gray-800 ${orientation === "landscape" ? "border-green-500" : ""}`} onClick={() => setOrientation("landscape")}>
                            <RectangleHorizontal className="w-8 h-8" color="green" strokeWidth={3} />
                            <p className="text-sm text-gray-400 mt-2">Horizontal</p>
                            <p className="text-xs text-gray-600">16:9</p>
                        </div>
                        <div className={`hover:cursor-pointer hover:border-green-500 transition-all duration-300 hover:bg-[#141414] w-full p-4 flex flex-col items-center justify-center rounded-lg bg-[#1b1b1b] border py-8 border-gray-800 ${orientation === "portrait" ? "border-green-500" : ""}`} onClick={() => setOrientation("portrait")}>
                            <RectangleVertical className="w-8 h-8" color="green" strokeWidth={3} />
                            <p className="text-sm text-gray-400 mt-2">Vertical</p>
                            <p className="text-xs text-gray-600">9:16</p>
                        </div>
                        <div className={`hover:cursor-pointer hover:border-green-500 transition-all duration-300 hover:bg-[#141414] w-full p-4 flex flex-col items-center justify-center rounded-lg bg-[#1b1b1b] border py-8 border-gray-800 ${orientation === "square" ? "border-green-500" : ""}`} onClick={() => setOrientation("square")}>
                            <Square className="w-8 h-8" color="green" strokeWidth={3} />
                            <p className="text-sm text-gray-400 mt-2">Square</p>
                            <p className="text-xs text-gray-600">1:1</p>
                        </div>
                    </div>
                </div>

                <div className="w-full p-4 flex flex-col items-start justify-start rounded-lg border border-gray-800">
                    <p>Select voice of speech</p>
                    <p className="text-xs mt-1 text-gray-400">Click to preview voices</p>
                    <div className="w-full p-4 gap-2 flex items-center justify-center">
                        {/* <button onClick={() => handleSelectVoice("us-male-1")} className="w-full p-4 flex flex-col items-center justify-center rounded-lg bg-[#1b1b1b] border py-8 border-gray-800 text-xs hover:bg-[#141414] hover:cursor-pointer"><span className="text-2xl text-blue-400">♂</span>Male 1</button>
                        <button onClick={() => handleSelectVoice("us-male-3")} className="w-full p-4 flex flex-col items-center justify-center rounded-lg bg-[#1b1b1b] border py-8 border-gray-800 text-xs hover:bg-[#141414] hover:cursor-pointer"><span className="text-2xl text-blue-400">♂</span>Male 2</button>
                        <button onClick={() => handleSelectVoice("us-female-1")} className="w-full p-4 flex flex-col items-center justify-center rounded-lg bg-[#1b1b1b] border py-8 border-gray-800 text-xs hover:bg-[#141414] hover:cursor-pointer"><span className="text-2xl text-pink-400">♀</span>Female 1</button>
                        <button onClick={() => handleSelectVoice("us-female-3")} className="w-full p-4 flex flex-col items-center justify-center rounded-lg bg-[#1b1b1b] border py-8 border-gray-800 text-xs hover:bg-[#141414] hover:cursor-pointer"><span className="text-2xl text-pink-400">♀</span>Female 2</button> */}

                        {options.map((option) => (
                            <label
                                key={option.id}
                                className={`
                                relative w-full cursor-pointer group
                                bg-[#181818] rounded-lg p-6
                                border transition-all duration-200
                                ${voice === option.id 
                                    ? 'border-green-500 ring-green-500 ring-opacity-50' 
                                    : 'border-gray-700 hover:border-green-600'
                                }
                                `}
                            >
                                <input
                                type="radio"
                                name="options"
                                value={option.id}
                                checked={voice === option.id}
                                onChange={(e) => handleSelectVoice(e.target.value)}
                                className="sr-only"
                                />
                                
                                {/* Check Circle */}
                                <div className="absolute top-3 right-3">
                                <CheckCircle2 
                                    className={`w-5 h-5 transition-all duration-200 ${
                                    voice === option.id 
                                        ? 'text-green-500 opacity-100 scale-100' 
                                        : 'text-gray-600 opacity-0 scale-90'
                                    }`}
                                />
                                </div>

                                {/* Content */}
                                <div className="flex flex-col items-center w-full text-center">
                                    <div className={`p-3 rounded-lg text-2xl transition-colors w-full duration-200 ${option.id === 'us-male-1' || option.id === 'us-male-3' ? 'text-blue-400' : 'text-pink-400'}`}>
                                        {option.icon}
                                    </div>
                                    <span className={`
                                        text-xs  transition-colors duration-200
                                        ${voice === option.id 
                                        ? 'text-white' 
                                        : 'text-gray-400'
                                        }
                                    `}>
                                        {option.label}
                                    </span>
                                </div>
                            </label>
                        ))}
                        
                    </div>
                </div>

                <div className="w-full p-4 flex flex-col items-start justify-start rounded-lg border border-gray-800">
                    <p className="border-b border-gray-800 w-full pb-1">Select subtitle style</p>
                    <div className="w-full p-4 gap-2 flex flex-col h-[500px] overflow-y-auto items-center justify-start">
                        {/* <button onClick={() => handleSelectVoice("us-male-1")} className="w-full p-4 flex flex-col items-center justify-center rounded-lg bg-[#1b1b1b] border py-8 border-gray-800 text-xs hover:bg-[#141414] hover:cursor-pointer"><span className="text-2xl text-blue-400">♂</span>Male 1</button>
                        <button onClick={() => handleSelectVoice("us-male-3")} className="w-full p-4 flex flex-col items-center justify-center rounded-lg bg-[#1b1b1b] border py-8 border-gray-800 text-xs hover:bg-[#141414] hover:cursor-pointer"><span className="text-2xl text-blue-400">♂</span>Male 2</button>
                        <button onClick={() => handleSelectVoice("us-female-1")} className="w-full p-4 flex flex-col items-center justify-center rounded-lg bg-[#1b1b1b] border py-8 border-gray-800 text-xs hover:bg-[#141414] hover:cursor-pointer"><span className="text-2xl text-pink-400">♀</span>Female 1</button>
                        <button onClick={() => handleSelectVoice("us-female-3")} className="w-full p-4 flex flex-col items-center justify-center rounded-lg bg-[#1b1b1b] border py-8 border-gray-800 text-xs hover:bg-[#141414] hover:cursor-pointer"><span className="text-2xl text-pink-400">♀</span>Female 2</button> */}

                        {subtitleOptions.map((option) => (
                            <label
                                key={option.id}
                                className={`
                                relative w-full cursor-pointer group
                                bg-[#181818] rounded-lg p-3
                                border transition-all duration-200
                                ${subtitle === option.id 
                                    ? 'border-green-500 ring-green-500 ring-opacity-50' 
                                    : 'border-gray-700 hover:border-green-600'
                                }
                                `}
                            >
                                <input
                                type="radio"
                                name="subtitle"
                                value={option.id}
                                checked={subtitle === option.id}
                                onChange={(e) => setSubtitle(e.target.value)}
                                className="sr-only"
                                />
                                
                                {/* Check Circle */}
                                <div className="absolute top-3 right-3">
                                <CheckCircle2 
                                    className={`w-5 h-5 transition-all duration-200 ${
                                    subtitle === option.id 
                                        ? 'text-green-500 opacity-100 scale-100' 
                                        : 'text-gray-600 opacity-0 scale-90'
                                    }`}
                                />
                                </div>

                                {/* Content */}
                                <div className="flex flex-col items-center w-full text-center">
                                    <span className={`
                                        text-xs  transition-colors duration-200
                                        ${subtitle === option.id 
                                        ? 'text-white' 
                                        : 'text-gray-400'
                                        }
                                    `}>
                                        {option.label}
                                    </span>
                                    <div className={`p-3 rounded-lg text-2xl transition-colors w-full duration-200 flex items-center justify-center`}>
                                        {/* {option.icon} */}
                                        <img src={`/assets/${option.id}.png`} alt="" className="w-[85%] h-auto object-cover rounded-md" />
                                    </div>
                                </div>
                            </label>
                        ))}
                        
                    </div>
                </div>

                <button onClick={startGeneration} className="hover:cursor-pointer hover:opacity-60 border border-green-500 bg-[#004d0d3f] hover:border-green-500 self-end text-white px-4 py-2 rounded-lg flex items-center justify-center gap-1">
                    Generate <Sparkles className="w-4 h-4"/>
                </button>
            </div>
            }

            {stage === Stage.VIDEO_GENERATION && !done && (
               <div className="w-[70%] z-20 p-4 gap-5 flex flex-col items-center justify-start">
                    <p className="w-full text-center text-2xl font-semibold">Hang Tight! We're generating your video!</p>

                    <div className="mt-20"></div>
                    <div className="flex my-5 items-center justify-center w-full">
                        <div className="loader"></div>
                    </div>

                    <div className="p-4 gap-2 flex flex-col items-start justify-start border border-gray-800 rounded-lg bg-[#1b1b1b]">
                        <p>Status: {message}</p>
                        <p className="flex items-center gap-2">Progress: <span className="text-green-500">{progress * 10}%</span></p>                        
                    </div>                    
                </div>  
            )}

            {stage === Stage.DONE && (
                <div className="w-[70%] z-20 p-4 flex flex-col items-center justify-start">
                    <p className="w-full text-center text-2xl font-semibold">🎉 Your video has been generated 🎉</p>
                    {/* <video className="mt-3 w-full my-5 h-auto rounded-lg" controls>
                        <source src="https://res.cloudinary.com/djc4fwyrc/video/upload/v1738160508/mOXWUrIShsghrgx2xIJ5I6nIFcA3/20250129_195146_final-sub-1738160500.4592862.mp4" type="video/mp4" />
                    </video> */}
                    <p className="w-full text-center mt-7 mb-3">Given prompt: {prompt}</p>
                    <iframe className="w-full rounded-lg h-96" 
                        src={videoUrl} allowFullScreen ></iframe>

                    <div className="w-full p-4 gap-5 flex items-center justify-between rounded-lg border border-gray-800">
                        <div className="flex w-full items-center justify-start gap-3">
                            <button
                                className="hover:cursor-pointer hover:opacity-60" 
                                onClick={() => {
                                    setVideoUrl('')
                                    setPrompt('')
                                    setOrientation('landscape')
                                    setStage(Stage.PROMPT)
                                    navigate(`/${cookies.get('uid')}/home`)
                                }}>
                                    <House className="w-5 h-5"/>
                            </button>
                            <button 
                                className="hover:cursor-pointer text-sm flex items-center justify-center hover:opacity-60" 
                                onClick={() => {
                                    setPrompt('')
                                    setVideoUrl('')
                                    setOrientation('landscape')
                                    setStage(Stage.PROMPT)
                                }}>
                                    <ArrowBigLeft className="w-5 h-5"/>
                                    Go back
                                </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    )
}