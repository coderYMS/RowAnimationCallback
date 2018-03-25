# RowAnimationCallback

最近有这样一个需求：
>cell展示内容，第一行高亮；用户读完第一行，第二个cell滚到顶，然后高亮；这样滚出去的cell不能再被滚回来；用户只能读一条，少一条。

大致效果是这样的：
<img src="http://144.202.36.88/source/deleterow.gif" title="demo image" title="delete row image" style="display:block; margin:auto" width="200"/>


中间这部分是随便扯一扯的，想看实现，直接跳到 [实现方案](#实现方案)

收到这个需求，觉得很简单：

1. 删除第一行
2. 将第二行滚到顶
3. 刷新新的第一行

前两步，很简单，一行代码搞定：

```
[table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] 
			withRowAnimation:UITableViewRowAnimationTop];

```
cell被delete之后，新的cell上来并不会刷新，所以需要手动更新下。
但是这个刷新时机遇到点小坑：

- 直接写<br>
	直接执行删除和reload这两行代码，delete的动画效果是需要时间的，但是后边reload又是立即执行的，总体出来的效果不理想，放弃。
- after：scrollViewDelegate<br>
	既然直接写不能实现效果，就想需要在动画结束之后，再执行后续操作。首先想到的就是scrollView的delegate。<br>
	点进去delegate，有这几个方法：
	
	- 	```
	scrollViewDidEndDecelerating:
	```
	<br>
	在```WillBeginDecelerating```的注释中写着 
	"called on finger up as we are moving"，也就是手动才会触发。不能用。<br>

	- 	```
	scrollViewDidEndScrollingAnimation:
	```
	<br>
	这个方法的注释里也写着"called when setContentOffset/scrollRectVisible:animated: finishes."，而table的rowAnimation也不会触发，不能用.

	- 其他的代理方法也没有完美匹配的。
	

- tricky方法<br>
	既然table和scroll的代理里没有明确给出回调的方法，那么就用一些替代方法。
	- 比如说，dispatch_after 0.5s 执行结束后的刷新。
	- 通过scroll滚动到相应的位置判断动画已经结束。
	- 等等等等
- 作为一个有追求的工程师，肯定是要去寻找真正的解决方案。

## 解决思路
删除cell调用的方法是：
```- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths 
withRowAnimation:(UITableViewRowAnimation)animation;
```
顾名思义，这是带有动画的。。。
顺着这个思路，尝试去给animation相关的方法打断点。

通过断点发现：在delete的过程中，执行了
```
[UIView(Animation) commitAnimations]
```

<img src="http://144.202.36.88/source/callstack.png" title="demo image" title="delete row image" style="display:block; margin:auto" width="200"/>

知道了rowAnimation，那么给这个animation加个回调就行了。<br>
首先想到的就是Core Animation的transaction。看官方文档：
>CATransaction allows you to override default animation properties that are set for animatable properties. You can customize duration, timing function, whether changes to properties trigger animations, <b>and provide a handler that informs you when all animations from the transaction group are completed.</b>

最后一句的意思就是可以回调了。<br>
而且官方还给了个demo，大意是这个begin()和commit()可以嵌套，先commit内侧动画，再commit外侧动画。


## <span id = "fangan">实现方案</span>
其实具体实现非常简单：

```

   	[CATransaction begin];
	[CATransaction setCompletionBlock:^{
		[_mainTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
					withRowAnimation:UITableViewRowAnimationNone];
	}];
	[_mainTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
				withRowAnimation:UITableViewRowAnimationTop];
	[CATransaction commit];
    
```

为了方便下次使用，封装了一个tableview的category

```
- (void)ym_animatAction:(void(^)(UITableView *table))action
               complete:(void(^)(UITableView *table))callback {
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        callback(self);
    }];
    action(self);
    [CATransaction commit];
}

```

使用时直接调用即可

```
    [_mainTable ym_animatAction:^(UITableView *table) {
        <#animat code#>
    } complete:^(UITableView *table) {
        <#complete code#>
    }];

```

## one more thing
这里使用CATransaction来处理这个动画，只是一个比较简洁的做法。<br>
同理，也有很多其他思路：比如说从UIView的```setAnimationDidStopSelector:```方法入手。以后有机会再来研究。




