import { Route, Routes } from "react-router-dom"
import LandingPage from "./components/landing/LandingPage"
import Home from "./components/home/Home"
import StockVideoGenerator from "./components/stockVideo/StockVideoGenerator"
import AiVideoGenerator from "./components/aiVideo/AiVideoGenerator"
import WebImgVideo from "./components/webImgVideo/WebImgVideo"
import Canvas from "./components/canvas/Canvas"
import History from "./components/history/History"

function App() {
  
  return (
    <div className="flex flex-col pb-24 justify-start text-white font-inter items-center min-h-screen w-full bg-[#080808]">
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/:uid/home" element={<Home />} />
        <Route path="/:uid/generate-video-from-stock" element={<StockVideoGenerator />} />
        <Route path="/:uid/generate-video-from-ai" element={<AiVideoGenerator />} />
        <Route path="/:uid/web-img-video" element={<WebImgVideo />} />
        <Route path="/:uid/canvas" element={<Canvas />} />
        <Route path="/:uid/history" element={<History />} />
      </Routes>
    </div>
  )
}

export default App
