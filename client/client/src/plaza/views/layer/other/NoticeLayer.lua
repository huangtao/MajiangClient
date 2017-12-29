--[[
	设置界面
	2015_12_03 C.P
	功能：音乐音量震动等
]]

local NoticeLayer = class("NoticeLayer", function(scene)
		local noticeLayer = display.newLayer(cc.c4b(0, 0, 0, 0))
    return noticeLayer
end)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local WebViewLayer = appdf.CLIENT_SRC .. "plaza.views.layer.plaza.WebViewLayer"
appdf.req(appdf.CLIENT_SRC.."plaza.models.FriendMgr")
local NotifyMgr = appdf.req(appdf.EXTERNAL_SRC .. "NotifyMgr")
local ModifyFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.ModifyFrame")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

NoticeLayer.BT_EXIT			= 1
NoticeLayer.PRO_WIDTH		= yl.WIDTH

function NoticeLayer:ctor(scene)
	self._scene = scene
	self:setContentSize(yl.WIDTH,yl.HEIGHT)
	local this = self

    --加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB("notice/noticeScene.csb", self)
    self.m_csbNode = csbNode

    --按钮事件
    local function btncallback(ref, type)
        if type == ccui.TouchEventType.ended then
         	self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

    --容器层
    local panel_1 =  csbNode:getChildByName("panel_1")

    --退出按钮
    self.m_btClose =  panel_1:getChildByName("bt_close")
    self.m_btClose:setTag(NoticeLayer.BT_EXIT)
    self.m_btClose:addTouchEventListener(btncallback)

    --初始化列表内容
    self:setNoticeFormSystemNotice()
    local content = self.m_csbNode:getChildByName("panel_noticeTxt")
    -- 滑动列表
    local tableView = cc.TableView:create(content:getContentSize())   
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(content:getPosition())
    --tableView:setPosition(cc.p(content:getPositionX(),content:getPositionY()))
    tableView:setDelegate()
    tableView:registerScriptHandler(self.cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.m_csbNode:addChild(tableView)
    self.m_tableView = tableView
    content:removeFromParent()
    self.m_tableView:reloadData()

end
function NoticeLayer:onButtonClickedEvent( tag, sender )
	if NoticeLayer.BT_EXIT == tag then		
		self._scene:onKeyBack()	
    else
        print("shareLayer按钮点击事件报错")		
	end
		
	
end
function NoticeLayer.cellSizeForTable(view, idx)
    return 800,80
end
function NoticeLayer:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then        
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end

   local tabData = {}
   tabData.strValue = self.m_strChatVoiceGame[idx+1]
   tabData.tag = idx + 1
   local item = self:createRecordItem(tabData)
   item:setPosition(view:getViewSize().width * 0.5, 25)
   cell:addChild(item)  

    return cell
end
function NoticeLayer:numberOfCellsInTableView(view)   
      return #self.m_strChatVoiceGame    
end
-- 创建记录
function NoticeLayer:createRecordItem(tabData)  
  
    local item = ccui.Widget:create()
    item:setContentSize(cc.size(800, 80))
    item:setTag(tabData.tag)
    
    -- 聊天内容   
    local str = tabData.strValue.str
    local strValue = cc.Label:createWithTTF(str,"fonts/round_body.ttf",30)  
    strValue:setTextColor(cc.c3b(124,74,20))
    strValue:setAnchorPoint(0,0.5)
    strValue:setVisible(false)
    item:addChild(strValue)
    strValue:setPosition(20,40)

    return item
end
function NoticeLayer:setNoticeFormSystemNotice()   
      self.m_strChatVoiceGame = {}
      self.m_strChatVoiceGame = self._scene:getNoticeListToNoticeLayer() 
--      if  #self.m_strChatVoiceGame == 0 then
--            self.m_strChatVoiceGame[1] = "测试公告：我是测试代码111111111111111111111111111111111111111111111111111111111111111111111111111"
--            self.m_strChatVoiceGame[2] = "测试公告：我是测试代码2"
--            self.m_strChatVoiceGame[3] = "测试公告：我是测试代码3"
--            self.m_strChatVoiceGame[4] = "测试公告：我是测试代码4"
--            self.m_strChatVoiceGame[5] = "测试公告：我是测试代码5"
--            self.m_strChatVoiceGame[6] = "测试公告：我是测试代码6"
--            self.m_strChatVoiceGame[7] = "测试公告：我是测试代码7"
--            self.m_strChatVoiceGame[8] = "测试公告：我是测试代码8"

--      end
end
return NoticeLayer