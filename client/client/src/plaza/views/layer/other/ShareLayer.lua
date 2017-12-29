--[[
	设置界面
	2015_12_03 C.P
	功能：音乐音量震动等
]]

local ShareLayer = class("ShareLayer", function(scene)
		local shareLayer = display.newLayer(cc.c4b(56, 56, 56, 56))
    return shareLayer
end)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local WebViewLayer = appdf.CLIENT_SRC .. "plaza.views.layer.plaza.WebViewLayer"
appdf.req(appdf.CLIENT_SRC.."plaza.models.FriendMgr")
local NotifyMgr = appdf.req(appdf.EXTERNAL_SRC .. "NotifyMgr")
local ModifyFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.ModifyFrame")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

ShareLayer.BT_SHARE   	    = 1
ShareLayer.BT_EXIT			= 2
ShareLayer.BT_SHARE_FRIEND  = 3
ShareLayer.PRO_WIDTH		= yl.WIDTH

function ShareLayer:ctor(scene)
	self._scene = scene
	self:setContentSize(yl.WIDTH,yl.HEIGHT)
	local this = self

	local areaWidth = yl.WIDTH
	local areaHeight = yl.HEIGHT

    --加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB("share/shartLayer.csb", self)
    self.m_csbNode = csbNode

    --按钮事件
    local function btncallback(ref, type)
        if type == ccui.TouchEventType.ended then
         	self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

    --容器层
    local pan_1 =  csbNode:getChildByName("pan_1")

    --退出按钮
    self.m_btClose =  csbNode:getChildByName("bt_close")
    self.m_btClose:setTag(ShareLayer.BT_EXIT)
    self.m_btClose:addTouchEventListener(btncallback)

    --分享按钮
    self.m_btShare =  pan_1:getChildByName("bt_share")
    self.m_btShare:setTag(ShareLayer.BT_SHARE)
    self.m_btShare:addTouchEventListener(btncallback)

     --分享按钮
    self.m_btShare =  pan_1:getChildByName("bt_share_friend")
    self.m_btShare:setTag(ShareLayer.BT_SHARE_FRIEND)
    self.m_btShare:addTouchEventListener(btncallback)

 
end
function ShareLayer:onButtonClickedEvent( tag, sender )
	if ShareLayer.BT_EXIT == tag then		
		self._scene:onKeyBack()
	elseif ShareLayer.BT_SHARE == tag then
        local function sharecall( isok )
            if type(isok) == "string" and isok == "true" then
                showToast(self, "分享完成", 1)
            end
        end
        local url = GlobalUserItem.szWXSpreaderURL or yl.HTTP_URL
        MultiPlatform:getInstance():shareToTarget(yl.ThirdParty.WECHAT_CIRCLE, sharecall, yl.SocialShare.title, yl.SocialShare.content, url)
    elseif ShareLayer.BT_SHARE_FRIEND == tag then
        local function sharecall( isok )
            if type(isok) == "string" and isok == "true" then
                showToast(self, "分享完成", 1)
            end
        end
        local url = GlobalUserItem.szWXSpreaderURL or yl.HTTP_URL
        MultiPlatform:getInstance():shareToTarget(yl.ThirdParty.WECHAT, sharecall, yl.SocialShare.title, yl.SocialShare.content, url)
    else
        print("shareLayer按钮点击事件报错")		
	end
		
	
end

return ShareLayer